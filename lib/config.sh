#!/usr/bin/env bash

# Configuration system for toolbox
# Loads user preferences with sensible defaults

# Default configuration values
DEFAULT_CONFIG=(
    "TOOLBOX_EDITOR=nano"
    "TOOLBOX_BACKUP_DIR=\$HOME/toolbox/backups"
    "TOOLBOX_LOG_LEVEL=error"
    "TOOLBOX_LOG_FILE=\$HOME/toolbox/toolbox.log"
    "TOOLBOX_AUTO_BACKUP=true"
    "TOOLBOX_CONFIRM_DELETE=true"
    "TOOLBOX_COLORS=true"
    "TOOLBOX_TIMESTAMP=true"
    "TOOLBOX_MAX_LOG_SIZE=10MB"
    "TOOLBOX_BACKUP_RETENTION=30"
)

# Load user configuration
load_config() {
    local config_file="$HOME/toolbox/config.sh"
    
    # Create default config if it doesn't exist
    if [[ ! -f "$config_file" ]]; then
        create_default_config "$config_file"
    fi
    
    # Load the configuration
    if [[ -f "$config_file" ]]; then
        source "$config_file"
    fi
    
    # Set defaults for any unset variables
    set_defaults
}

# Create default configuration file
create_default_config() {
    local config_file="$1"
    local config_dir="$(dirname "$config_file")"
    
    # Create directory if it doesn't exist
    mkdir -p "$config_dir"
    
    # Create config file with defaults
    cat > "$config_file" << 'EOF'
#!/usr/bin/env bash
# Toolbox Configuration File
# Edit this file to customize toolbox behavior

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
export TOOLBOX_SUPPRESS_INIT="false"            # Suppress initialization messages
EOF

    info "Created default configuration at $config_file"
    info "Edit this file to customize toolbox behavior"
}

# Set default values for any unset variables
set_defaults() {
    # Editor
    [[ -z "$TOOLBOX_EDITOR" ]] && export TOOLBOX_EDITOR="cursor"
    
    # Backup settings
    [[ -z "$TOOLBOX_BACKUP_DIR" ]] && export TOOLBOX_BACKUP_DIR="$HOME/toolbox/backups"
    [[ -z "$TOOLBOX_AUTO_BACKUP" ]] && export TOOLBOX_AUTO_BACKUP="true"
    [[ -z "$TOOLBOX_BACKUP_RETENTION" ]] && export TOOLBOX_BACKUP_RETENTION="30"
    
    # Logging settings
    [[ -z "$TOOLBOX_LOG_LEVEL" ]] && export TOOLBOX_LOG_LEVEL="info"
    [[ -z "$TOOLBOX_LOG_FILE" ]] && export TOOLBOX_LOG_FILE="$HOME/toolbox/toolbox.log"
    [[ -z "$TOOLBOX_MAX_LOG_SIZE" ]] && export TOOLBOX_MAX_LOG_SIZE="10MB"
    
    # Safety settings
    [[ -z "$TOOLBOX_CONFIRM_DELETE" ]] && export TOOLBOX_CONFIRM_DELETE="true"
    
    # Display settings
    [[ -z "$TOOLBOX_COLORS" ]] && export TOOLBOX_COLORS="true"
    [[ -z "$TOOLBOX_TIMESTAMP" ]] && export TOOLBOX_TIMESTAMP="true"
    
    # Advanced settings
    [[ -z "$TOOLBOX_DEBUG" ]] && export TOOLBOX_DEBUG="false"
    [[ -z "$TOOLBOX_QUIET" ]] && export TOOLBOX_QUIET="false"
    [[ -z "$TOOLBOX_SUPPRESS_INIT" ]] && export TOOLBOX_SUPPRESS_INIT="false"
}

# Get configuration value
get_config() {
    local key="$1"
    local default="$2"
    
    if [[ -n "${!key}" ]]; then
        echo "${!key}"
    else
        echo "$default"
    fi
}

# Set configuration value
set_config() {
    local key="$1"
    local value="$2"
    local config_file="$HOME/toolbox/config.sh"
    
    if [[ -f "$config_file" ]]; then
        # Update the config file
        if grep -q "^export $key=" "$config_file"; then
            sed -i "s/^export $key=.*/export $key=\"$value\"/" "$config_file"
        else
            echo "export $key=\"$value\"" >> "$config_file"
        fi
        export "$key=$value"
        success "Updated $key to $value"
    else
        error "Configuration file not found. Run 'toolbox config init' first."
    fi
}

# Show current configuration
show_config() {
    local config_file="$HOME/toolbox/config.sh"
    
    if [[ -f "$config_file" ]]; then
        info "Current configuration:"
        echo ""
        cat "$config_file" | grep -E "^export" | while read line; do
            local key=$(echo "$line" | cut -d'=' -f1 | sed 's/export //')
            local value=$(echo "$line" | cut -d'=' -f2- | sed 's/"//g')
            echo "  $key: $value"
        done
    else
        error "Configuration file not found. Run 'toolbox config init' first."
    fi
}

# Initialize configuration
init_config() {
    local config_file="$HOME/toolbox/config.sh"
    create_default_config "$config_file"
} 