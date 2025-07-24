#!/usr/bin/env bash

# Backup command for toolbox
# Allows users to create, list, restore, and manage backups

backup_command() {
    local subcommand="$1"
    shift || true
    
    case "$subcommand" in
        create)
            if [[ $# -lt 1 ]]; then
                error "Usage: toolbox backup create <source> [backup_name]"
                return 1
            fi
            create_backup "$1" "$2"
            ;;
        list)
            list_backups "$1"
            ;;
        restore)
            if [[ $# -lt 1 ]]; then
                error "Usage: toolbox backup restore <backup_path> [restore_path]"
                return 1
            fi
            restore_backup "$1" "$2"
            ;;
        clean)
            clean_old_backups
            ;;
        info)
            if [[ $# -lt 1 ]]; then
                error "Usage: toolbox backup info <backup_path>"
                return 1
            fi
            backup_info "$1"
            ;;
        stats|statistics)
            backup_stats
            ;;
        *)
            show_backup_help
            ;;
    esac
}

show_backup_help() {
    cat << 'EOF'
Backup Management

Usage:
  toolbox backup create <source> [name]     # Create backup of file/directory
  toolbox backup list [pattern]             # List all backups (optionally filtered)
  toolbox backup restore <backup> [dest]    # Restore from backup
  toolbox backup clean                      # Clean old backups
  toolbox backup info <backup>              # Show backup information
  toolbox backup stats                      # Show backup statistics

Examples:
  toolbox backup create important_file.txt
  toolbox backup create project/ my_project_backup
  toolbox backup list "*.txt"
  toolbox backup restore backup_20241201_143022
  toolbox backup restore backup_20241201_143022 ./restored_file.txt
  toolbox backup clean
  toolbox backup info backup_20241201_143022

Auto-backup:
  The toolbox automatically creates backups before destructive operations
  when TOOLBOX_AUTO_BACKUP is enabled.

Configuration:
  TOOLBOX_BACKUP_DIR       # Backup directory location
  TOOLBOX_AUTO_BACKUP      # Enable/disable auto-backup
  TOOLBOX_BACKUP_RETENTION # Days to keep backups
  TOOLBOX_CONFIRM_DELETE   # Confirm before overwriting during restore
EOF
} 