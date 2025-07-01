#!/bin/bash
# Dotfiles CLI - Central command-line interface for dotfiles management
# Provides a unified interface to all dotfiles utilities

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define command
COMMAND="$1"
shift || true

# Show help if no command
if [ -z "$COMMAND" ]; then
  cat << EOF
Unified command-line interface for dotfiles management

USAGE:
  $(basename "$0") COMMAND [OPTIONS] [ARGS]

COMMANDS:
  sync          - Sync dotfiles between local system and repository
  pkg           - Manage system packages
  migrate       - Migrate system configurations
  diag          - Run system diagnostics
  backup        - Backup important data
  help          - Show help for a specific command

OPTIONS:
  -h, --help     Show this help message and exit
  -v, --verbose  Show verbose output
  -q, --quiet    Suppress all output except errors
  -n, --dry-run  Show what would be done without making changes

EXAMPLES:
  $(basename "$0") sync --pull     # Sync dotfiles from repository to home
  $(basename "$0") pkg update    # Update system packages
  $(basename "$0") migrate backup  # Backup system configuration
  $(basename "$0") help sync     # Show help for sync command
EOF
  exit 0
fi

# Pass command to appropriate script
case "$COMMAND" in
  sync|dotfiles)
    # Sync dotfiles
    "$SCRIPT_DIR/run_dotfiles_sync.sh" "$@"
    ;;
    
  pkg|package|packages)
    # Manage packages
    PKG_CMD="$1"
    shift || true
    
    case "$PKG_CMD" in
      update|upgrade)
        "$SCRIPT_DIR/run_pkg_update.sh" "$@"
        ;;
      clean)
        "$SCRIPT_DIR/run_pkg_clean.sh" "$@"
        ;;
      healthcheck|check)
        "$SCRIPT_DIR/run_pkg_healthcheck.sh" "$@"
        ;;
      *)
        echo "ERROR: Unknown package command: $PKG_CMD"
        echo "Available package commands: update, clean, healthcheck"
        exit 1
        ;;
    esac
    ;;
    
  migrate|migration)
    # System migration
    MIGRATE_CMD="$1"
    shift || true
    
    case "$MIGRATE_CMD" in
      backup)
        "$SCRIPT_DIR/run_migrate_system.sh" backup "$@"
        ;;
      restore)
        "$SCRIPT_DIR/run_migrate_system.sh" restore "$@"
        ;;
      flatpak)
        "$SCRIPT_DIR/run_migrate_system.sh" flatpak "$@"
        ;;
      gnome-to-kde|gnome2kde)
        "$SCRIPT_DIR/run_migrate_system.sh" migrate --from=gnome --to=kde "$@"
        ;;
      kde-to-gnome|kde2gnome)
        "$SCRIPT_DIR/run_migrate_system.sh" migrate --from=kde --to=gnome "$@"
        ;;
      *)
        echo "ERROR: Unknown migration command: $MIGRATE_CMD"
        echo "Available migration commands: backup, restore, flatpak, gnome-to-kde, kde-to-gnome"
        exit 1
        ;;
    esac
    ;;
    
  diag|diagnostics)
    # System diagnostics
    DIAG_CMD="$1"
    shift || true
    
    case "$DIAG_CMD" in
      system|all)
        "$SCRIPT_DIR/run_diag_system.sh" "$@"
        ;;
      network)
        "$SCRIPT_DIR/run_diag_network.sh" "$@"
        ;;
      performance)
        "$SCRIPT_DIR/run_diag_performance.sh" "$@"
        ;;
      *)
        # Default to system diagnostics if no subcommand
        "$SCRIPT_DIR/run_diag_system.sh" "$@"
        ;;
    esac
    ;;
    
  backup)
    # Backup utilities
    BACKUP_CMD="$1"
    shift || true
    
    case "$BACKUP_CMD" in
      btrfs)
        "$SCRIPT_DIR/run_backup_btrfs.sh" "$@"
        ;;
      documents)
        "$SCRIPT_DIR/run_backup_documents.sh" "$@"
        ;;
      gnome)
        "$SCRIPT_DIR/run_backup_gnome_settings.sh" "$@"
        ;;
      *)
        echo "ERROR: Unknown backup command: $BACKUP_CMD"
        echo "Available backup commands: btrfs, documents, gnome"
        exit 1
        ;;
    esac
    ;;
    
  help)
    # Show help for a specific command
    HELP_CMD="$1"
    shift || true
    
    case "$HELP_CMD" in
      sync|dotfiles)
        "$SCRIPT_DIR/run_dotfiles_sync.sh" --help
        ;;
      pkg|package|packages)
        "$SCRIPT_DIR/run_pkg_update.sh" --help
        ;;
      migrate|migration)
        "$SCRIPT_DIR/run_migrate_system.sh" --help
        ;;
      diag|diagnostics)
        "$SCRIPT_DIR/run_diag_system.sh" --help
        ;;
      backup)
        echo "Backup commands:"
        echo "  btrfs      - Backup using BTRFS snapshots"
        echo "  documents  - Backup important documents"
        echo "  gnome      - Backup GNOME settings"
        ;;
      *)
        # Show general help
        cat << EOF
Unified command-line interface for dotfiles management

USAGE:
  $(basename "$0") COMMAND [OPTIONS] [ARGS]

COMMANDS:
  sync          - Sync dotfiles between local system and repository
  pkg           - Manage system packages
  migrate       - Migrate system configurations
  diag          - Run system diagnostics
  backup        - Backup important data
  help          - Show help for a specific command

OPTIONS:
  -h, --help     Show this help message and exit
  -v, --verbose  Show verbose output
  -q, --quiet    Suppress all output except errors
  -n, --dry-run  Show what would be done without making changes

EXAMPLES:
  $(basename "$0") sync --pull     # Sync dotfiles from repository to home
  $(basename "$0") pkg update    # Update system packages
  $(basename "$0") migrate backup  # Backup system configuration
  $(basename "$0") help sync     # Show help for sync command
EOF
        ;;
    esac
    ;;
    
  *)
    # Check if it's a direct script
    SCRIPT_PATH="$SCRIPT_DIR/run_$COMMAND.sh"
    if [ -f "$SCRIPT_PATH" ] && [ -x "$SCRIPT_PATH" ]; then
      "$SCRIPT_PATH" "$@"
    else
      echo "ERROR: Unknown command: $COMMAND"
      cat << EOF
Unified command-line interface for dotfiles management

USAGE:
  $(basename "$0") COMMAND [OPTIONS] [ARGS]

COMMANDS:
  sync          - Sync dotfiles between local system and repository
  pkg           - Manage system packages
  migrate       - Migrate system configurations
  diag          - Run system diagnostics
  backup        - Backup important data
  help          - Show help for a specific command

OPTIONS:
  -h, --help     Show this help message and exit
  -v, --verbose  Show verbose output
  -q, --quiet    Suppress all output except errors
  -n, --dry-run  Show what would be done without making changes

EXAMPLES:
  $(basename "$0") sync --pull     # Sync dotfiles from repository to home
  $(basename "$0") pkg update    # Update system packages
  $(basename "$0") migrate backup  # Backup system configuration
  $(basename "$0") help sync     # Show help for sync command
EOF
      exit 1
    fi
    ;;
esac