#!/bin/bash
# dependency_checker.sh - Find missing dependencies across development projects

set -e

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default search directory is current directory
SEARCH_DIR="${1:-.}"

check_npm_deps() {
  local search_dir="$1"
  echo -e "${BLUE}📦 Checking NPM dependencies...${NC}"
  
  # Find all package.json files
  local package_files=$(find "$search_dir" -name "package.json" -not -path "*/node_modules/*" -not -path "*/\.*/*")
  
  if [ -z "$package_files" ]; then
    echo -e "${YELLOW}No Node.js projects found.${NC}"
    return
  fi
  
  echo -e "Found $(echo "$package_files" | wc -l) Node.js projects"
  
  echo "$package_files" | while read -r file; do
    local dir=$(dirname "$file")
    echo -e "\n${BLUE}📂 Checking ${dir}${NC}"
    
    # Check if project has node_modules
    if [ ! -d "${dir}/node_modules" ]; then
      echo -e "${YELLOW}⚠️  node_modules not found. Dependencies not installed.${NC}"
      continue
    fi
    
    # Check for outdated packages
    echo -e "${GREEN}Checking for outdated packages...${NC}"
    (cd "$dir" && npm outdated --depth=0 2>/dev/null || echo -e "${YELLOW}⚠️ Error checking packages${NC}")
    
    # Check for security vulnerabilities (npm 6+)
    echo -e "${GREEN}Checking for security vulnerabilities...${NC}"
    (cd "$dir" && npm audit --production 2>/dev/null || echo -e "${YELLOW}⚠️ Error checking vulnerabilities${NC}")
  done
}

check_python_deps() {
  local search_dir="$1"
  echo -e "\n${BLUE}🐍 Checking Python dependencies...${NC}"
  
  # Find all requirements.txt files
  local req_files=$(find "$search_dir" -name "requirements.txt" -o -name "Pipfile" -o -name "pyproject.toml" | grep -v "venv\|\.git")
  
  if [ -z "$req_files" ]; then
    echo -e "${YELLOW}No Python projects found.${NC}"
    return
  fi
  
  echo -e "Found $(echo "$req_files" | wc -l) Python projects"
  
  echo "$req_files" | while read -r file; do
    local dir=$(dirname "$file")
    local file_name=$(basename "$file")
    echo -e "\n${BLUE}📂 Checking ${dir} (${file_name})${NC}"
    
    case "$file_name" in
      "requirements.txt")
        if command -v pip >/dev/null; then
          # Check if packages are installed
          echo -e "${GREEN}Checking package installation status...${NC}"
          if [ -d "${dir}/venv" ]; then
            (source "${dir}/venv/bin/activate" 2>/dev/null && pip check || echo -e "${YELLOW}⚠️ Missing dependencies detected${NC}")
          else
            echo -e "${YELLOW}⚠️ No virtualenv found at ${dir}/venv${NC}"
          fi
        else
          echo -e "${YELLOW}⚠️ pip not found${NC}"
        fi
        ;;
      "Pipfile")
        if command -v pipenv >/dev/null; then
          echo -e "${GREEN}Checking Pipfile dependencies with pipenv...${NC}"
          (cd "$dir" && pipenv check 2>/dev/null || echo -e "${YELLOW}⚠️ Issues found with dependencies${NC}")
        else
          echo -e "${YELLOW}⚠️ pipenv not found${NC}"
        fi
        ;;
      "pyproject.toml")
        if command -v poetry >/dev/null; then
          echo -e "${GREEN}Checking Poetry dependencies...${NC}"
          (cd "$dir" && poetry check 2>/dev/null || echo -e "${YELLOW}⚠️ Issues found with dependencies${NC}")
        else
          echo -e "${YELLOW}⚠️ poetry not found${NC}"
        fi
        ;;
    esac
  done
}

check_go_deps() {
  local search_dir="$1"
  echo -e "\n${BLUE}🔄 Checking Go dependencies...${NC}"
  
  # Find all go.mod files
  local go_files=$(find "$search_dir" -name "go.mod" -not -path "*/\.*/*")
  
  if [ -z "$go_files" ]; then
    echo -e "${YELLOW}No Go projects found.${NC}"
    return
  fi
  
  echo -e "Found $(echo "$go_files" | wc -l) Go projects"
  
  echo "$go_files" | while read -r file; do
    local dir=$(dirname "$file")
    echo -e "\n${BLUE}📂 Checking ${dir}${NC}"
    
    if command -v go >/dev/null; then
      # Verify modules
      echo -e "${GREEN}Verifying modules...${NC}"
      (cd "$dir" && go mod verify 2>&1)
      
      # Check for unused dependencies
      echo -e "${GREEN}Checking for unused dependencies...${NC}"
      (cd "$dir" && (go mod tidy -v 2>&1 || echo -e "${YELLOW}⚠️ Issues found with dependencies${NC}"))
    else
      echo -e "${YELLOW}⚠️ Go not found${NC}"
    fi
  done
}

check_rust_deps() {
  local search_dir="$1"
  echo -e "\n${BLUE}⚙️ Checking Rust dependencies...${NC}"
  
  # Find all Cargo.toml files
  local cargo_files=$(find "$search_dir" -name "Cargo.toml" -not -path "*/target/*" -not -path "*/\.*/*")
  
  if [ -z "$cargo_files" ]; then
    echo -e "${YELLOW}No Rust projects found.${NC}"
    return
  fi
  
  echo -e "Found $(echo "$cargo_files" | wc -l) Rust projects"
  
  echo "$cargo_files" | while read -r file; do
    local dir=$(dirname "$file")
    echo -e "\n${BLUE}📂 Checking ${dir}${NC}"
    
    if command -v cargo >/dev/null; then
      # Check for outdated dependencies
      echo -e "${GREEN}Checking for outdated dependencies...${NC}"
      (cd "$dir" && cargo outdated 2>/dev/null || echo -e "${YELLOW}⚠️ cargo-outdated not installed. Install with: cargo install cargo-outdated${NC}")
      
      # Audit dependencies for security vulnerabilities
      echo -e "${GREEN}Auditing dependencies for security vulnerabilities...${NC}"
      (cd "$dir" && cargo audit 2>/dev/null || echo -e "${YELLOW}⚠️ cargo-audit not installed. Install with: cargo install cargo-audit${NC}")
    else
      echo -e "${YELLOW}⚠️ Cargo not found${NC}"
    fi
  done
}

check_all() {
  local search_dir="$1"
  echo -e "${BLUE}🔍 Checking all dependencies in ${search_dir}${NC}\n"
  
  check_npm_deps "$search_dir"
  check_python_deps "$search_dir"
  check_go_deps "$search_dir"
  check_rust_deps "$search_dir"
  
  echo -e "\n${GREEN}✅ Dependency check complete!${NC}"
}

# Main execution
if [ $# -eq 0 ]; then
  # No args, print help
  echo "Dependency Checker - Find missing dependencies across development projects"
  echo ""
  echo "Usage: dependency_checker.sh [command] [directory]"
  echo ""
  echo "Commands:"
  echo "  npm     - Check Node.js dependencies"
  echo "  python  - Check Python dependencies"
  echo "  go      - Check Go dependencies"
  echo "  rust    - Check Rust dependencies"
  echo "  all     - Check all dependencies (default if directory provided)"
  echo ""
  echo "If no command is specified but a directory is, all dependency types will be checked."
  echo "If no directory is specified, the current directory will be used."
  echo ""
  echo "Examples:"
  echo "  dependency_checker.sh npm ~/projects"
  echo "  dependency_checker.sh python ."
  echo "  dependency_checker.sh all ~/code"
  echo "  dependency_checker.sh ~/code  # Same as 'all ~/code'"
  exit 0
fi

# Check if first arg is a directory
if [ -d "$1" ]; then
  # First arg is a directory, check all dependency types
  check_all "$1"
  exit 0
fi

# First arg is a command
case "$1" in
  npm|node|nodejs)
    check_npm_deps "${2:-.}"
    ;;
  python|py)
    check_python_deps "${2:-.}"
    ;;
  go|golang)
    check_go_deps "${2:-.}"
    ;;
  rust|cargo)
    check_rust_deps "${2:-.}"
    ;;
  all)
    check_all "${2:-.}"
    ;;
  *)
    echo "Unknown command: $1"
    echo "Available commands: npm, python, go, rust, all"
    exit 1
    ;;
esac