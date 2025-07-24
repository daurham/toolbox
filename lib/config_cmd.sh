#!/usr/bin/env bash

# Configuration command for toolbox
# Allows users to view, set, and manage configuration

config_command() {
    local subcommand="$1"
    shift || true
    
    case "$subcommand" in
        show|list)
            show_config
            ;;
        set)
            if [[ $# -lt 2 ]]; then
                error "Usage: toolbox config set <key> <value>"
                return 1
            fi
            set_config "$1" "$2"
            ;;
        init)
            init_config
            ;;
        reset)
            local config_file="$HOME/toolbox/config.sh"
            if [[ -f "$config_file" ]]; then
                rm "$config_file"
                success "Configuration reset. Run 'toolbox config init' to recreate."
            else
                warn "No configuration file to reset"
            fi
            ;;
        edit)
            local config_file="$HOME/toolbox/config.sh"
            if [[ -f "$config_file" ]]; then
                $TOOLBOX_EDITOR "$config_file"
            else
                error "Configuration file not found. Run 'toolbox config init' first."
            fi
            ;;
        *)
            show_config_help
            ;;
    esac
}

show_config_help() {
    cat << 'EOF'
Configuration Management

Usage:
  toolbox config show              # Show current configuration
  toolbox config set <key> <value> # Set configuration value
  toolbox config init              # Initialize default configuration
  toolbox config reset             # Reset configuration to defaults
  toolbox config edit              # Edit configuration file

Available settings:
  TOOLBOX_EDITOR           # Default editor (nano, vim, code, etc.)
  TOOLBOX_BACKUP_DIR       # Backup directory path
  TOOLBOX_AUTO_BACKUP      # Auto-backup before destructive operations (true/false)
  TOOLBOX_BACKUP_RETENTION # Days to keep backups
  TOOLBOX_LOG_LEVEL        # Log level (debug, info, warn, error)
  TOOLBOX_LOG_FILE         # Log file location
  TOOLBOX_MAX_LOG_SIZE     # Maximum log file size
  TOOLBOX_CONFIRM_DELETE   # Confirm before deleting files (true/false)
  TOOLBOX_COLORS           # Enable colored output (true/false)
  TOOLBOX_TIMESTAMP        # Show timestamps in logs (true/false)
  TOOLBOX_DEBUG            # Enable debug mode (true/false)
  TOOLBOX_QUIET            # Suppress non-error output (true/false)
  TOOLBOX_SUPPRESS_INIT    # Suppress initialization messages (true/false)

Examples:
  toolbox config set TOOLBOX_EDITOR "code"
  toolbox config set TOOLBOX_AUTO_BACKUP "false"
  toolbox config set TOOLBOX_LOG_LEVEL "debug"
  toolbox config set TOOLBOX_SUPPRESS_INIT "true"  # Reduce clutter
EOF
} 