#!/bin/bash
# project_switcher.sh - Quickly switch between common projects

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Config
PROJECT_FILE="$HOME/.project_paths.conf"
EDITOR="${EDITOR:-vim}"

# Create config if it doesn't exist
if [ ! -f "$PROJECT_FILE" ]; then
  echo "# Project paths - one per line in format: name=/path/to/project" > "$PROJECT_FILE"
  echo "# Example: dotfiles=$HOME/dotfiles" >> "$PROJECT_FILE"
  echo -e "${GREEN}Created new project file at $PROJECT_FILE${NC}"
fi

add_project() {
  if [ -z "$1" ] || [ -z "$2" ]; then
    echo -e "${YELLOW}Usage: project_switcher.sh add <name> <path>${NC}"
    exit 1
  fi
  
  name=$1
  path=$(realpath "$2")
  
  if ! [ -d "$path" ]; then
    echo -e "${YELLOW}Error: Directory $path does not exist${NC}"
    exit 1
  fi
  
  # Check if already exists
  if grep -q "^$name=" "$PROJECT_FILE"; then
    sed -i "/^$name=/d" "$PROJECT_FILE"
    echo -e "${GREEN}Updated project $name${NC}"
  else
    echo -e "${GREEN}Added project $name${NC}"
  fi
  
  echo "$name=$path" >> "$PROJECT_FILE"
  sort -o "$PROJECT_FILE" "$PROJECT_FILE"
}

remove_project() {
  if [ -z "$1" ]; then
    echo -e "${YELLOW}Usage: project_switcher.sh remove <name>${NC}"
    exit 1
  fi
  
  name=$1
  
  if grep -q "^$name=" "$PROJECT_FILE"; then
    sed -i "/^$name=/d" "$PROJECT_FILE"
    echo -e "${GREEN}Removed project $name${NC}"
  else
    echo -e "${YELLOW}Error: Project $name not found${NC}"
    exit 1
  fi
}

list_projects() {
  echo -e "${BLUE}Available projects:${NC}"
  echo ""
  
  # Calculate max length for name column
  max_name_length=10
  while IFS='=' read -r name path || [[ -n "$name" ]]; do
    # Skip comments and empty lines
    [[ $name =~ ^#.*$ ]] && continue
    [[ -z "$name" ]] && continue
    
    length=${#name}
    if (( length > max_name_length )); then
      max_name_length=$length
    fi
  done < "$PROJECT_FILE"
  
  # Add some padding
  max_name_length=$((max_name_length + 2))
  
  # Display projects with colored output
  while IFS='=' read -r name path || [[ -n "$name" ]]; do
    # Skip comments and empty lines
    [[ $name =~ ^#.*$ ]] && continue
    [[ -z "$name" ]] && continue
    
    # Check if directory still exists
    if [ -d "$path" ]; then
      status="${GREEN}✓${NC}"
    else
      status="${YELLOW}✗${NC}"
    fi
    
    printf "  ${CYAN}%-${max_name_length}s${NC} %s %s\n" "$name" "$path" "$status"
  done < "$PROJECT_FILE"
  
  echo ""
  echo -e "${BLUE}Legend:${NC}"
  echo -e "  ${GREEN}✓${NC} Directory exists"
  echo -e "  ${YELLOW}✗${NC} Directory not found"
}

goto_project() {
  if [ -z "$1" ]; then
    echo -e "${YELLOW}Usage: project_switcher.sh goto <name>${NC}"
    exit 1
  fi
  
  name=$1
  path=$(grep "^$name=" "$PROJECT_FILE" | cut -d'=' -f2)
  
  if [ -z "$path" ]; then
    echo -e "${YELLOW}Error: Project $name not found${NC}"
    exit 1
  fi
  
  if ! [ -d "$path" ]; then
    echo -e "${YELLOW}Warning: Directory $path does not exist${NC}"
  fi
  
  # We need to affect the parent shell, so we print the command to execute
  echo "cd $path"
}

search_projects() {
  if [ -z "$1" ]; then
    echo -e "${YELLOW}Usage: project_switcher.sh search <term>${NC}"
    exit 1
  fi
  
  term=$1
  echo -e "${BLUE}Projects matching '$term':${NC}\n"
  
  found=false
  while IFS='=' read -r name path || [[ -n "$name" ]]; do
    # Skip comments and empty lines
    [[ $name =~ ^#.*$ ]] && continue
    [[ -z "$name" ]] && continue
    
    if [[ "$name" == *"$term"* ]] || [[ "$path" == *"$term"* ]]; then
      found=true
      printf "  ${CYAN}%-20s${NC} %s\n" "$name" "$path"
    fi
  done < "$PROJECT_FILE"
  
  if [ "$found" = false ]; then
    echo -e "${YELLOW}No projects found matching '$term'${NC}"
  fi
}

edit_projects() {
  $EDITOR "$PROJECT_FILE"
}

scan_directory() {
  local dir="${1:-.}"
  local prefix="${2:-}"
  
  echo -e "${BLUE}Scanning $dir for Git repositories...${NC}"
  
  # Find all Git repositories
  find "$dir" -type d -name ".git" -not -path "*/node_modules/*" -not -path "*/\.*/*" | while read -r gitdir; do
    repo_dir=$(dirname "$gitdir")
    repo_name=$(basename "$repo_dir")
    
    # Add prefix if provided
    if [ -n "$prefix" ]; then
      project_name="${prefix}_${repo_name}"
    else
      project_name="$repo_name"
    fi
    
    # Check if already exists
    if grep -q "^$project_name=" "$PROJECT_FILE"; then
      echo -e "${YELLOW}Project $project_name already exists, skipping${NC}"
    else
      add_project "$project_name" "$repo_dir"
    fi
  done
}

# Check if being sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  # Define the function to be used in bashrc/zshrc
  goto() {
    if [ -z "$1" ]; then
      project_switcher.sh list
      return
    fi
    
    cmd=$(project_switcher.sh goto "$1")
    if [ $? -eq 0 ]; then
      eval "$cmd"
      echo -e "${GREEN}Switched to project: $1${NC}"
    fi
  }
  
  # Export the function
  export -f goto
  return
fi

case "$1" in
  add)
    shift
    add_project "$@"
    ;;
  remove|rm|delete)
    shift
    remove_project "$@"
    ;;
  list|ls)
    list_projects
    ;;
  goto|cd)
    goto_project "$2"
    ;;
  search|find)
    search_projects "$2"
    ;;
  scan)
    scan_directory "$2" "$3"
    ;;
  edit)
    edit_projects
    ;;
  *)
    echo -e "${PURPLE}Project Switcher${NC}"
    echo -e "${BLUE}A tool to quickly navigate between projects${NC}"
    echo ""
    echo -e "${CYAN}Usage:${NC} project_switcher.sh <command> [options]"
    echo ""
    echo -e "${CYAN}Commands:${NC}"
    echo "  add <name> <path>  - Add/update a project"
    echo "  remove <name>      - Remove a project"
    echo "  list               - List available projects"
    echo "  goto <name>        - Go to project directory (use with eval)"
    echo "  search <term>      - Search for projects"
    echo "  scan <dir> [prefix]- Scan directory for Git repos and add them"
    echo "  edit               - Edit projects file"
    echo ""
    echo -e "${CYAN}Examples:${NC}"
    echo "  project_switcher.sh add dotfiles $HOME/dotfiles"
    echo "  project_switcher.sh list"
    echo "  eval \$(project_switcher.sh goto dotfiles)"
    echo "  project_switcher.sh scan $HOME/projects work"
    echo ""
    echo -e "${CYAN}For easier use, add this to your .bashrc or .zshrc:${NC}"
    echo '  source /path/to/project_switcher.sh'
    echo '  alias proj="project_switcher.sh"'
    echo ""
    echo -e "${CYAN}Then you can use:${NC}"
    echo "  goto dotfiles      - Switch to a project"
    echo "  proj list          - List projects"
    exit 1
    ;;
esac