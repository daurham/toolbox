#!/usr/bin/env bash
# Toolbox Configuration File Example

# Editor preferences
export TOOLBOX_EDITOR="cursor"                  # Default editor (nano, vim, code, cursor, etc.)

# Backup settings
export TOOLBOX_BACKUP_DIR="$HOME/toolbox/backups"  # Backup directory
export TOOLBOX_AUTO_BACKUP="true"               # Auto-backup before destructive operations
export TOOLBOX_BACKUP_RETENTION="30"            # Days to keep backups

# Logging settings
export TOOLBOX_LOG_LEVEL="error"                 # debug, info, warn, error
export TOOLBOX_LOG_FILE="$HOME/toolbox/toolbox.log"  # Log file location
export TOOLBOX_MAX_LOG_SIZE="10MB"              # Max log file size

# Safety settings
export TOOLBOX_CONFIRM_DELETE="true"            # Confirm before deleting files

# Display settings
export TOOLBOX_COLORS="true"                    # Enable colored output
export TOOLBOX_TIMESTAMP="true"                 # Show timestamps in logs

# Advanced settings
export TOOLBOX_DEBUG="false"                    # Enable debug mode
export TOOLBOX_QUIET="false"                    # Suppress non-error output
export TOOLBOX_SUPPRESS_INIT="true"            # Suppress initialization messages
