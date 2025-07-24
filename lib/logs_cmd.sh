#!/usr/bin/env bash

# Logs command for toolbox
# Allows users to view, clear, and manage logs

logs_command() {
    local subcommand="$1"
    shift || true
    
    case "$subcommand" in
        show|view|tail)
            local lines="${1:-50}"
            show_logs "$lines"
            ;;
        clear|clean)
            clear_logs
            ;;
        stats|statistics)
            log_stats
            ;;
        rotate)
            local log_file="$TOOLBOX_LOG_FILE"
            if [[ -f "$log_file" ]]; then
                rotate_log_file "$log_file"
            else
                warn "No log file to rotate"
            fi
            ;;
        *)
            show_logs_help
            ;;
    esac
}

show_logs_help() {
    cat << 'EOF'
Log Management

Usage:
  toolbox logs show [lines]     # Show recent logs (default: 50 lines)
  toolbox logs clear            # Clear all logs
  toolbox logs stats            # Show log statistics
  toolbox logs rotate           # Rotate log file

Examples:
  toolbox logs show 100         # Show last 100 lines
  toolbox logs show             # Show last 50 lines
  toolbox logs clear            # Clear all logs
  toolbox logs stats            # Show log statistics

Log levels:
  debug - Detailed debugging information
  info  - General information messages
  warn  - Warning messages
  error - Error messages

Configuration:
  TOOLBOX_LOG_LEVEL     # Set minimum log level
  TOOLBOX_LOG_FILE      # Set log file location
  TOOLBOX_MAX_LOG_SIZE  # Set maximum log file size
  TOOLBOX_TIMESTAMP     # Enable/disable timestamps
EOF
} 