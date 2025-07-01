#!/bin/bash
# sys_benchmark.sh - Run quick performance tests and track over time

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

BENCHMARK_DIR="$HOME/.benchmarks"
CURRENT_DATE=$(date +"%Y-%m-%d")
RESULTS_FILE="$BENCHMARK_DIR/benchmark_results.csv"
CHARTS_DIR="$BENCHMARK_DIR/charts"

mkdir -p "$BENCHMARK_DIR"
mkdir -p "$CHARTS_DIR"

# Initialize results file if it doesn't exist
if [ ! -f "$RESULTS_FILE" ]; then
  echo "date,cpu_single,cpu_multi,disk_read,disk_write,memory_speed" > "$RESULTS_FILE"
fi

# Function to run CPU benchmark (single-threaded)
run_cpu_benchmark_single() {
  echo -e "${BLUE}🧮 Running CPU single-thread benchmark...${NC}"
  # Use bc to calculate pi to 5000 digits and measure time
  time_start=$(date +%s.%N)
  echo "scale=5000; 4*a(1)" | bc -l > /dev/null 2>&1
  time_end=$(date +%s.%N)
  time_diff=$(echo "$time_end - $time_start" | bc)
  echo -e "${GREEN}CPU single-threaded score: $time_diff seconds (lower is better)${NC}"
  echo "$time_diff"
}

# Function to run CPU benchmark (multi-threaded)
run_cpu_benchmark_multi() {
  echo -e "${BLUE}🧮 Running CPU multi-thread benchmark...${NC}"
  # Use parallel gzip compression as a multi-threaded test
  if ! command -v parallel >/dev/null; then
    echo -e "${YELLOW}GNU parallel not found. Score: N/A${NC}"
    echo "N/A" 
    return
  fi
  
  # Create 100MB test file if it doesn't exist
  test_file="$BENCHMARK_DIR/test_file_100MB"
  if [ ! -f "$test_file" ]; then
    dd if=/dev/urandom of="$test_file" bs=1M count=100 2>/dev/null
  fi
  
  time_start=$(date +%s.%N)
  cat "$test_file" | parallel --pipe -j$(nproc) gzip -c > /dev/null
  time_end=$(date +%s.%N)
  time_diff=$(echo "$time_end - $time_start" | bc)
  echo -e "${GREEN}CPU multi-threaded score: $time_diff seconds (lower is better)${NC}"
  echo "$time_diff"
}

# Function to run disk benchmark
run_disk_benchmark() {
  echo -e "${BLUE}💾 Running disk I/O benchmark...${NC}"
  test_file="$BENCHMARK_DIR/disk_test_file"
  
  # Disk write test (1GB)
  echo -e "${CYAN}Writing 1GB test file...${NC}"
  time_start=$(date +%s.%N)
  dd if=/dev/zero of="$test_file" bs=1M count=1024 conv=fdatasync 2>/dev/null
  time_end=$(date +%s.%N)
  write_time=$(echo "$time_end - $time_start" | bc)
  write_speed=$(echo "1024 / $write_time" | bc)
  echo -e "${GREEN}Disk write speed: $write_speed MB/s${NC}"
  
  # Disk read test
  echo -e "${CYAN}Reading test file...${NC}"
  # Try to drop caches - requires sudo
  sync
  if command -v sudo >/dev/null && sudo -n true 2>/dev/null; then
    echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null 2>&1
  else
    echo -e "${YELLOW}Note: Could not drop caches. Read test may be inaccurate.${NC}"
    sleep 3
  fi
  
  time_start=$(date +%s.%N)
  dd if="$test_file" of=/dev/null bs=1M 2>/dev/null
  time_end=$(date +%s.%N)
  read_time=$(echo "$time_end - $time_start" | bc)
  read_speed=$(echo "1024 / $read_time" | bc)
  echo -e "${GREEN}Disk read speed: $read_speed MB/s${NC}"
  
  # Clean up
  rm -f "$test_file"
  
  echo "$read_speed"
  echo "$write_speed"
}

# Function to run memory benchmark
run_memory_benchmark() {
  echo -e "${BLUE}🧠 Running memory benchmark...${NC}"
  
  # Create memory test file
  cat > "$BENCHMARK_DIR/memory_test.py" << 'EOF'
import time
import numpy as np

# Create a large array (1GB)
size_gb = 1
size_bytes = size_gb * 1024 * 1024 * 1024

# Calculate array dimensions for 1GB
array_size = int((size_bytes / 8) ** 0.5)  # Using 8 bytes per double

print(f"Creating {size_gb}GB array ({array_size}x{array_size})...")
time_start = time.time()

# Create a large array
a = np.zeros((array_size, array_size), dtype=np.float64)

# Fill with data
for i in range(array_size):
    a[i] = i

# Copy the array to measure memory bandwidth
b = a.copy()

time_end = time.time()
elapsed = time_end - time_start

# Calculate memory bandwidth (read+write so multiply by 2)
bandwidth_gbps = (2 * size_gb) / elapsed

print(f"Memory bandwidth: {bandwidth_gbps:.2f} GB/s")
print(bandwidth_gbps)
EOF
  
  # Check if numpy is installed
  if ! command -v python3 >/dev/null; then
    echo -e "${YELLOW}Python 3 not found. Memory benchmark skipped.${NC}"
    echo "N/A"
    return
  fi
  
  if ! python3 -c "import numpy" 2>/dev/null; then
    echo -e "${YELLOW}NumPy not found. Memory benchmark skipped.${NC}"
    echo "N/A"
    return
  fi
  
  # Run the memory test
  result=$(python3 "$BENCHMARK_DIR/memory_test.py" 2>/dev/null | tail -1)
  echo -e "${GREEN}Memory bandwidth: $result GB/s${NC}"
  
  echo "$result"
}

# Function to create a simple chart
create_chart() {
  local metric=$1
  local title=$2
  local output_file="${CHARTS_DIR}/${metric}_chart.html"
  
  # Extract the data for the chart
  echo "Creating chart for $title..."
  
  # Use awk to extract just date and the metric column
  awk -F, -v col="$metric" 'NR==1 {for (i=1; i<=NF; i++) if ($i == col) col_idx = i}
       {print $1 "," $col_idx}' "$RESULTS_FILE" > "$BENCHMARK_DIR/temp_data.csv"
  
  # Create a simple HTML chart
  cat > "$output_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>$title Benchmark History</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .container { width: 800px; margin: 0 auto; }
        h1 { color: #333; text-align: center; }
    </style>
</head>
<body>
    <div class="container">
        <h1>$title Benchmark History</h1>
        <canvas id="benchmarkChart"></canvas>
    </div>
    <script>
        // Load the data
        const data = [
EOF
  
  # Skip header and add data points
  tail -n +2 "$BENCHMARK_DIR/temp_data.csv" | while IFS=, read -r date value; do
    if [[ "$value" != "N/A" ]]; then
      echo "            { date: '$date', value: $value }," >> "$output_file"
    fi
  done
  
  # Close the chart script
  cat >> "$output_file" << EOF
        ];
        
        // Create the chart
        const ctx = document.getElementById('benchmarkChart').getContext('2d');
        new Chart(ctx, {
            type: 'line',
            data: {
                labels: data.map(item => item.date),
                datasets: [{
                    label: '$title',
                    data: data.map(item => item.value),
                    backgroundColor: 'rgba(75, 192, 192, 0.2)',
                    borderColor: 'rgba(75, 192, 192, 1)',
                    borderWidth: 2,
                    tension: 0.1
                }]
            },
            options: {
                scales: {
                    y: {
                        beginAtZero: false
                    }
                },
                plugins: {
                    title: {
                        display: true,
                        text: '$title Benchmark (Run on $(date +"%Y-%m-%d"))'
                    }
                }
            }
        });
    </script>
</body>
</html>
EOF
  
  echo -e "${GREEN}Chart created: $output_file${NC}"
  rm "$BENCHMARK_DIR/temp_data.csv"
}

# Function to create a dashboard with all charts
create_dashboard() {
  local output_file="${CHARTS_DIR}/dashboard.html"
  
  echo "Creating benchmark dashboard..."
  
  cat > "$output_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>System Benchmark Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .container { width: 90%; margin: 0 auto; }
        h1 { color: #333; text-align: center; }
        .charts-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; margin-top: 20px; }
        .chart-container { border: 1px solid #ddd; padding: 15px; border-radius: 5px; }
        .system-info { margin: 20px 0; padding: 15px; background-color: #f5f5f5; border-radius: 5px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 8px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <div class="container">
        <h1>System Benchmark Dashboard</h1>
        
        <div class="system-info">
            <h2>System Information</h2>
            <table>
                <tr><th>Hostname</th><td>$(hostname)</td></tr>
                <tr><th>CPU</th><td>$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^[ \t]*//')</td></tr>
                <tr><th>Cores</th><td>$(grep -c processor /proc/cpuinfo)</td></tr>
                <tr><th>Memory</th><td>$(free -h | grep Mem | awk '{print $2}')</td></tr>
                <tr><th>OS</th><td>$(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '"')</td></tr>
                <tr><th>Kernel</th><td>$(uname -r)</td></tr>
                <tr><th>Last Benchmark</th><td>$(date)</td></tr>
            </table>
        </div>
        
        <div class="charts-grid">
            <div class="chart-container">
                <h2>CPU Single-Thread Performance</h2>
                <iframe src="cpu_single_chart.html" width="100%" height="400" frameborder="0"></iframe>
            </div>
            <div class="chart-container">
                <h2>CPU Multi-Thread Performance</h2>
                <iframe src="cpu_multi_chart.html" width="100%" height="400" frameborder="0"></iframe>
            </div>
            <div class="chart-container">
                <h2>Disk Read Speed</h2>
                <iframe src="disk_read_chart.html" width="100%" height="400" frameborder="0"></iframe>
            </div>
            <div class="chart-container">
                <h2>Disk Write Speed</h2>
                <iframe src="disk_write_chart.html" width="100%" height="400" frameborder="0"></iframe>
            </div>
            <div class="chart-container">
                <h2>Memory Speed</h2>
                <iframe src="memory_speed_chart.html" width="100%" height="400" frameborder="0"></iframe>
            </div>
        </div>
        
        <div class="system-info">
            <h2>Raw Benchmark Results</h2>
            <pre>$(tail -10 "$RESULTS_FILE" | column -t -s,)</pre>
        </div>
    </div>
</body>
</html>
EOF
  
  echo -e "${GREEN}Dashboard created: $output_file${NC}"
}

# Function to run all benchmarks and save results
run_all_benchmarks() {
  echo -e "${PURPLE}🚀 Running all benchmarks...${NC}"
  
  # Get system info
  echo -e "\n${BLUE}📋 System Information:${NC}"
  echo -e "${CYAN}CPU:${NC} $(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^[ \t]*//')"
  echo -e "${CYAN}Cores:${NC} $(grep -c processor /proc/cpuinfo)"
  echo -e "${CYAN}Memory:${NC} $(free -h | grep Mem | awk '{print $2}')"
  echo -e "${CYAN}OS:${NC} $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '"')"
  echo -e "${CYAN}Kernel:${NC} $(uname -r)"
  echo ""
  
  cpu_single=$(run_cpu_benchmark_single)
  echo ""
  
  cpu_multi=$(run_cpu_benchmark_multi)
  echo ""
  
  disk_result=$(run_disk_benchmark)
  disk_read=$(echo "$disk_result" | head -1)
  disk_write=$(echo "$disk_result" | tail -1)
  echo ""
  
  memory=$(run_memory_benchmark)
  echo ""
  
  # Save results to CSV
  echo "$CURRENT_DATE,$cpu_single,$cpu_multi,$disk_read,$disk_write,$memory" >> "$RESULTS_FILE"
  
  echo -e "${GREEN}✅ Benchmark completed. Results saved to $RESULTS_FILE${NC}"
  
  # Create charts
  echo -e "\n${BLUE}📊 Generating benchmark charts...${NC}"
  create_chart "cpu_single" "CPU Single-Thread"
  create_chart "cpu_multi" "CPU Multi-Thread"
  create_chart "disk_read" "Disk Read Speed"
  create_chart "disk_write" "Disk Write Speed"
  create_chart "memory_speed" "Memory Bandwidth"
  create_dashboard
  
  echo -e "\n${GREEN}✅ Benchmark dashboard created at ${CHARTS_DIR}/dashboard.html${NC}"
  echo -e "${YELLOW}Note: Open this file in a browser to view the charts${NC}"
}

# Function to show benchmark history
show_history() {
  if [ ! -f "$RESULTS_FILE" ]; then
    echo -e "${YELLOW}No benchmark history found.${NC}"
    exit 0
  fi
  
  echo -e "${BLUE}📊 Benchmark history:${NC}\n"
  if command -v column >/dev/null; then
    column -t -s, "$RESULTS_FILE" | head -1 | sed 's/^/  /'
    echo "  $(printf '%0.s-' $(seq 1 80))"
    column -t -s, "$RESULTS_FILE" | tail -n +2 | sed 's/^/  /'
  else
    cat "$RESULTS_FILE" | sed 's/^/  /'
  fi
  
  echo -e "\n${YELLOW}Note: View detailed charts in ${CHARTS_DIR}/dashboard.html${NC}"
}

# Function to generate a report
generate_report() {
  if [ ! -f "$RESULTS_FILE" ]; then
    echo -e "${YELLOW}No benchmark history found.${NC}"
    exit 0
  fi
  
  # Get the most recent results
  recent=$(tail -1 "$RESULTS_FILE")
  recent_date=$(echo "$recent" | cut -d, -f1)
  recent_cpu_single=$(echo "$recent" | cut -d, -f2)
  recent_cpu_multi=$(echo "$recent" | cut -d, -f3)
  recent_disk_read=$(echo "$recent" | cut -d, -f4)
  recent_disk_write=$(echo "$recent" | cut -d, -f5)
  recent_memory=$(echo "$recent" | cut -d, -f6)
  
  # Get the second most recent results for comparison (if available)
  if [ $(wc -l < "$RESULTS_FILE") -gt 2 ]; then
    prev=$(tail -2 "$RESULTS_FILE" | head -1)
    prev_date=$(echo "$prev" | cut -d, -f1)
    prev_cpu_single=$(echo "$prev" | cut -d, -f2)
    prev_cpu_multi=$(echo "$prev" | cut -d, -f3)
    prev_disk_read=$(echo "$prev" | cut -d, -f4)
    prev_disk_write=$(echo "$prev" | cut -d, -f5)
    prev_memory=$(echo "$prev" | cut -d, -f6)
    
    # Calculate percentage changes
    if [[ "$prev_cpu_single" != "N/A" && "$recent_cpu_single" != "N/A" ]]; then
      cpu_single_change=$(echo "scale=2; (($prev_cpu_single - $recent_cpu_single) / $prev_cpu_single) * 100" | bc)
      # For CPU, lower is better so invert the sign
      cpu_single_change=$(echo "scale=2; $cpu_single_change * 1" | bc)
    else
      cpu_single_change="N/A"
    fi
    
    if [[ "$prev_cpu_multi" != "N/A" && "$recent_cpu_multi" != "N/A" ]]; then
      cpu_multi_change=$(echo "scale=2; (($prev_cpu_multi - $recent_cpu_multi) / $prev_cpu_multi) * 100" | bc)
      # For CPU, lower is better so invert the sign
      cpu_multi_change=$(echo "scale=2; $cpu_multi_change * 1" | bc)
    else
      cpu_multi_change="N/A"
    fi
    
    if [[ "$prev_disk_read" != "N/A" && "$recent_disk_read" != "N/A" ]]; then
      disk_read_change=$(echo "scale=2; (($recent_disk_read - $prev_disk_read) / $prev_disk_read) * 100" | bc)
    else
      disk_read_change="N/A"
    fi
    
    if [[ "$prev_disk_write" != "N/A" && "$recent_disk_write" != "N/A" ]]; then
      disk_write_change=$(echo "scale=2; (($recent_disk_write - $prev_disk_write) / $prev_disk_write) * 100" | bc)
    else
      disk_write_change="N/A"
    fi
    
    if [[ "$prev_memory" != "N/A" && "$recent_memory" != "N/A" ]]; then
      memory_change=$(echo "scale=2; (($recent_memory - $prev_memory) / $prev_memory) * 100" | bc)
    else
      memory_change="N/A"
    fi
  fi
  
  # Print the report
  echo -e "${PURPLE}💻 System Benchmark Report${NC}"
  echo -e "${BLUE}Generated:${NC} $(date)"
  echo -e "${BLUE}System:${NC} $(hostname) - $(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^[ \t]*//')"
  echo -e "${BLUE}OS:${NC} $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d '"')"
  echo ""
  
  echo -e "${CYAN}Most Recent Benchmark (${recent_date}):${NC}"
  echo "  CPU Single-Thread: ${recent_cpu_single} seconds"
  echo "  CPU Multi-Thread: ${recent_cpu_multi} seconds"
  echo "  Disk Read: ${recent_disk_read} MB/s"
  echo "  Disk Write: ${recent_disk_write} MB/s"
  echo "  Memory Bandwidth: ${recent_memory} GB/s"
  echo ""
  
  if [ $(wc -l < "$RESULTS_FILE") -gt 2 ]; then
    echo -e "${CYAN}Comparison with previous benchmark (${prev_date}):${NC}"
    
    if [[ "$cpu_single_change" != "N/A" ]]; then
      if (( $(echo "$cpu_single_change >= 0" | bc -l) )); then
        echo -e "  CPU Single-Thread: ${GREEN}+${cpu_single_change}%${NC} (Improvement)"
      else
        echo -e "  CPU Single-Thread: ${RED}${cpu_single_change}%${NC} (Decline)"
      fi
    else
      echo "  CPU Single-Thread: No comparison available"
    fi
    
    if [[ "$cpu_multi_change" != "N/A" ]]; then
      if (( $(echo "$cpu_multi_change >= 0" | bc -l) )); then
        echo -e "  CPU Multi-Thread: ${GREEN}+${cpu_multi_change}%${NC} (Improvement)"
      else
        echo -e "  CPU Multi-Thread: ${RED}${cpu_multi_change}%${NC} (Decline)"
      fi
    else
      echo "  CPU Multi-Thread: No comparison available"
    fi
    
    if [[ "$disk_read_change" != "N/A" ]]; then
      if (( $(echo "$disk_read_change >= 0" | bc -l) )); then
        echo -e "  Disk Read: ${GREEN}+${disk_read_change}%${NC} (Improvement)"
      else
        echo -e "  Disk Read: ${RED}${disk_read_change}%${NC} (Decline)"
      fi
    else
      echo "  Disk Read: No comparison available"
    fi
    
    if [[ "$disk_write_change" != "N/A" ]]; then
      if (( $(echo "$disk_write_change >= 0" | bc -l) )); then
        echo -e "  Disk Write: ${GREEN}+${disk_write_change}%${NC} (Improvement)"
      else
        echo -e "  Disk Write: ${RED}${disk_write_change}%${NC} (Decline)"
      fi
    else
      echo "  Disk Write: No comparison available"
    fi
    
    if [[ "$memory_change" != "N/A" ]]; then
      if (( $(echo "$memory_change >= 0" | bc -l) )); then
        echo -e "  Memory Bandwidth: ${GREEN}+${memory_change}%${NC} (Improvement)"
      else
        echo -e "  Memory Bandwidth: ${RED}${memory_change}%${NC} (Decline)"
      fi
    else
      echo "  Memory Bandwidth: No comparison available"
    fi
  fi
  
  echo -e "\n${YELLOW}Note: View detailed charts in ${CHARTS_DIR}/dashboard.html${NC}"
}

# Main
case "$1" in
  cpu)
    run_cpu_benchmark_single
    run_cpu_benchmark_multi
    ;;
  disk)
    run_disk_benchmark
    ;;
  memory)
    run_memory_benchmark
    ;;
  history)
    show_history
    ;;
  charts)
    echo -e "${BLUE}📊 Generating benchmark charts...${NC}"
    create_chart "cpu_single" "CPU Single-Thread"
    create_chart "cpu_multi" "CPU Multi-Thread"
    create_chart "disk_read" "Disk Read Speed"
    create_chart "disk_write" "Disk Write Speed"
    create_chart "memory_speed" "Memory Bandwidth"
    create_dashboard
    echo -e "${GREEN}✅ Charts created in $CHARTS_DIR${NC}"
    ;;
  report)
    generate_report
    ;;
  help|--help|-h)
    echo -e "${PURPLE}System Benchmark${NC}"
    echo -e "${BLUE}A tool to benchmark system performance and track changes over time${NC}"
    echo ""
    echo -e "${CYAN}Usage:${NC} sys_benchmark.sh [command]"
    echo ""
    echo -e "${CYAN}Commands:${NC}"
    echo "  (no command)  - Run all benchmarks"
    echo "  cpu           - Run CPU benchmarks (single & multi-threaded)"
    echo "  disk          - Run disk I/O benchmark"
    echo "  memory        - Run memory benchmark"
    echo "  history       - Show benchmark history"
    echo "  charts        - Generate benchmark charts"
    echo "  report        - Generate a brief performance report"
    echo "  help          - Show this help message"
    ;;
  *)
    run_all_benchmarks
    ;;
esac