#!/usr/bin/env bash

# Enhanced logging system for toolbox
# Supports multiple log levels, file rotation, and timestamps

# Log levels (numeric for comparison)
LOG_LEVEL_DEBUG=0
LOG_LEVEL_INFO=1
LOG_LEVEL_WARN=2
LOG_LEVEL_ERROR=3

# Get current log level as number
get_log_level_num() {
    case "$TOOLBOX_LOG_LEVEL" in
        debug) echo $LOG_LEVEL_DEBUG ;;
        info)  echo $LOG_LEVEL_INFO ;;
        warn)  echo $LOG_LEVEL_WARN ;;
        error) echo $LOG_LEVEL_ERROR ;;
        *)     echo $LOG_LEVEL_INFO ;;
    esac
}

# Check if we should log at this level
should_log() {
    local level="$1"
    local current_level=$(get_log_level_num)
    local message_level=0
    
    case "$level" in
        debug) message_level=$LOG_LEVEL_DEBUG ;;
        info)  message_level=$LOG_LEVEL_INFO ;;
        warn)  message_level=$LOG_LEVEL_WARN ;;
        error) message_level=$LOG_LEVEL_ERROR ;;
    esac
    
    [[ $message_level -ge $current_level ]]
}

# Get timestamp for logging
get_timestamp() {
    if [[ "$TOOLBOX_TIMESTAMP" == "true" ]]; then
        date '+%Y-%m-%d %H:%M:%S'
    else
        echo ""
    fi
}

# Write to log file
write_log() {
    local level="$1"
    local message="$2"
    local timestamp=$(get_timestamp)
    local log_file="$TOOLBOX_LOG_FILE"
    
    # Create log directory if it doesn't exist
    local log_dir="$(dirname "$log_file")"
    mkdir -p "$log_dir"
    
    # Format log entry
    if [[ -n "$timestamp" ]]; then
        echo "[$timestamp] [$level] $message" >> "$log_file"
    else
        echo "[$level] $message" >> "$log_file"
    fi
    
    # Check log file size and rotate if needed
    check_log_rotation "$log_file"
}

# Check and rotate log file if it's too large
check_log_rotation() {
    local log_file="$1"
    local max_size="$TOOLBOX_MAX_LOG_SIZE"
    
    if [[ -f "$log_file" ]]; then
        local current_size=$(stat -c%s "$log_file" 2>/dev/null || stat -f%z "$log_file" 2>/dev/null || echo 0)
        local max_bytes=0
        
        # Convert max_size to bytes
        if [[ "$max_size" =~ ^([0-9]+)MB$ ]]; then
            max_bytes=$(( ${BASH_REMATCH[1]} * 1024 * 1024 ))
        elif [[ "$max_size" =~ ^([0-9]+)KB$ ]]; then
            max_bytes=$(( ${BASH_REMATCH[1]} * 1024 ))
        elif [[ "$max_size" =~ ^([0-9]+)B$ ]]; then
            max_bytes=${BASH_REMATCH[1]}
        else
            max_bytes=$(( 10 * 1024 * 1024 ))  # Default 10MB
        fi
        
        if [[ $current_size -gt $max_bytes ]]; then
            rotate_log_file "$log_file"
        fi
    fi
}

# Rotate log file
rotate_log_file() {
    local log_file="$1"
    local backup_file="${log_file}.$(date +%Y%m%d_%H%M%S)"
    
    if [[ -f "$log_file" ]]; then
        mv "$log_file" "$backup_file"
        info "Log file rotated to $backup_file"
    fi
}

# Enhanced logging functions
log_debug() {
    local message="$1"
    if should_log "debug"; then
        if [[ "$TOOLBOX_DEBUG" == "true" ]]; then
            echo -e "${GRAY}🐛 DEBUG: $message${RESET}" >&2
        fi
        write_log "DEBUG" "$message"
    fi
}

log_info() {
    local message="$1"
    if should_log "info"; then
        if [[ "$TOOLBOX_QUIET" != "true" ]]; then
            info "$message"
        fi
        write_log "INFO" "$message"
    fi
}

log_warn() {
    local message="$1"
    if should_log "warn"; then
        if [[ "$TOOLBOX_QUIET" != "true" ]]; then
            warn "$message"
        fi
        write_log "WARN" "$message"
    fi
}

log_error() {
    local message="$1"
    if should_log "error"; then
        error "$message"
        write_log "ERROR" "$message"
    fi
}

# Log command execution
log_command() {
    local command="$1"
    local args="$2"
    local result="$3"
    
    log_info "Command: $command $args"
    if [[ -n "$result" ]]; then
        log_info "Result: $result"
    fi
}

# Log file operations
log_file_op() {
    local operation="$1"
    local file="$2"
    local details="$3"
    
    local message="File $operation: $file"
    if [[ -n "$details" ]]; then
        message="$message ($details)"
    fi
    
    log_info "$message"
}

# Show recent logs
show_logs() {
    local lines="${1:-50}"
    local log_file="$TOOLBOX_LOG_FILE"
    
    if [[ -f "$log_file" ]]; then
        info "Recent logs (last $lines lines):"
        echo ""
        tail -n "$lines" "$log_file"
    else
        warn "No log file found at $log_file"
    fi
}

# Clear logs
clear_logs() {
    local log_file="$TOOLBOX_LOG_FILE"
    
    if [[ -f "$log_file" ]]; then
        > "$log_file"
        success "Logs cleared"
    else
        warn "No log file found to clear"
    fi
}

# Get log statistics
log_stats() {
    local log_file="$TOOLBOX_LOG_FILE"
    
    if [[ -f "$log_file" ]]; then
        info "Log statistics:"
        echo "  File: $log_file"
        echo "  Size: $(du -h "$log_file" | cut -f1)"
        echo "  Lines: $(wc -l < "$log_file")"
        echo "  Last modified: $(stat -c%y "$log_file" 2>/dev/null || stat -f%Sm "$log_file" 2>/dev/null)"
        
        echo ""
        echo "  Log levels:"
        echo "    DEBUG: $(grep -c "\[DEBUG\]" "$log_file" 2>/dev/null || echo 0)"
        echo "    INFO:  $(grep -c "\[INFO\]" "$log_file" 2>/dev/null || echo 0)"
        echo "    WARN:  $(grep -c "\[WARN\]" "$log_file" 2>/dev/null || echo 0)"
        echo "    ERROR: $(grep -c "\[ERROR\]" "$log_file" 2>/dev/null || echo 0)"
    else
        warn "No log file found"
    fi
}

# Initialize logging
init_logging() {
    local log_file="$TOOLBOX_LOG_FILE"
    local log_dir="$(dirname "$log_file")"
    
    mkdir -p "$log_dir"
    
    # Log initialization (only if not suppressed)
    if [[ "$TOOLBOX_SUPPRESS_INIT" != "true" ]]; then
        log_info "Toolbox logging initialized"
        log_info "Log level: $TOOLBOX_LOG_LEVEL"
        log_info "Log file: $log_file"
    fi
} 