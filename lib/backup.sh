#!/usr/bin/env bash

# Backup system for toolbox
# Provides automatic backups, retention policies, and restore functionality

# Create backup of a file or directory
create_backup() {
    local source="$1"
    local backup_name="$2"
    local backup_dir="$TOOLBOX_BACKUP_DIR"
    
    # Validate source
    if [[ ! -e "$source" ]]; then
        log_error "Backup source does not exist: $source"
        return 1
    fi
    
    # Create backup directory if it doesn't exist
    mkdir -p "$backup_dir"
    
    # Generate backup name if not provided
    if [[ -z "$backup_name" ]]; then
        local basename=$(basename "$source")
        local timestamp=$(date +%Y%m%d_%H%M%S)
        backup_name="${basename}_${timestamp}"
    fi
    
    local backup_path="$backup_dir/$backup_name"
    
    # Create backup
    if [[ -d "$source" ]]; then
        # Directory backup
        if cp -r "$source" "$backup_path" 2>/dev/null; then
            log_info "Directory backup created: $backup_path"
            echo "$backup_path"
        else
            log_error "Failed to create directory backup: $source"
            return 1
        fi
    else
        # File backup
        if cp "$source" "$backup_path" 2>/dev/null; then
            log_info "File backup created: $backup_path"
            echo "$backup_path"
        else
            log_error "Failed to create file backup: $source"
            return 1
        fi
    fi
}

# Auto-backup before destructive operations
auto_backup() {
    local source="$1"
    local operation="$2"
    
    if [[ "$TOOLBOX_AUTO_BACKUP" == "true" ]]; then
        log_info "Creating auto-backup before $operation: $source"
        create_backup "$source" >/dev/null
    fi
}

# List all backups
list_backups() {
    local backup_dir="$TOOLBOX_BACKUP_DIR"
    local pattern="$1"
    
    if [[ ! -d "$backup_dir" ]]; then
        warn "No backup directory found at $backup_dir"
        return 1
    fi
    
    info "Available backups:"
    echo ""
    
    if [[ -n "$pattern" ]]; then
        find "$backup_dir" -name "*$pattern*" -type f -o -name "*$pattern*" -type d | sort
    else
        find "$backup_dir" -maxdepth 1 -type f -o -type d | grep -v "^$backup_dir$" | sort
    fi
    
    echo ""
    local total_backups=$(find "$backup_dir" -maxdepth 1 -type f -o -type d | grep -v "^$backup_dir$" | wc -l)
    info "Total backups: $total_backups"
}

# Restore from backup
restore_backup() {
    local backup_path="$1"
    local restore_path="$2"
    
    # Validate backup exists
    if [[ ! -e "$backup_path" ]]; then
        log_error "Backup not found: $backup_path"
        return 1
    fi
    
    # If restore path not specified, restore to original location
    if [[ -z "$restore_path" ]]; then
        local backup_name=$(basename "$backup_path")
        # Try to extract original name (remove timestamp)
        restore_path=$(echo "$backup_name" | sed 's/_[0-9]\{8\}_[0-9]\{6\}$//')
        restore_path="./$restore_path"
    fi
    
    # Check if restore path already exists
    if [[ -e "$restore_path" ]]; then
        if [[ "$TOOLBOX_CONFIRM_DELETE" == "true" ]]; then
            read -p "Restore path already exists. Overwrite? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                log_info "Restore cancelled"
                return 1
            fi
        fi
    fi
    
    # Perform restore
    if [[ -d "$backup_path" ]]; then
        # Directory restore
        if cp -r "$backup_path" "$restore_path" 2>/dev/null; then
            log_info "Directory restored: $backup_path -> $restore_path"
            success "Restore completed successfully"
        else
            log_error "Failed to restore directory: $backup_path"
            return 1
        fi
    else
        # File restore
        if cp "$backup_path" "$restore_path" 2>/dev/null; then
            log_info "File restored: $backup_path -> $restore_path"
            success "Restore completed successfully"
        else
            log_error "Failed to restore file: $backup_path"
            return 1
        fi
    fi
}

# Clean old backups based on retention policy
clean_old_backups() {
    local backup_dir="$TOOLBOX_BACKUP_DIR"
    local retention_days="$TOOLBOX_BACKUP_RETENTION"
    
    if [[ ! -d "$backup_dir" ]]; then
        log_info "No backup directory to clean"
        return 0
    fi
    
    local cutoff_date=$(date -d "$retention_days days ago" +%s 2>/dev/null || date -v-${retention_days}d +%s 2>/dev/null)
    local cleaned_count=0
    
    info "Cleaning backups older than $retention_days days..."
    
    find "$backup_dir" -maxdepth 1 -type f -o -type d | while read -r backup; do
        if [[ "$backup" != "$backup_dir" ]]; then
            local backup_date=$(stat -c%Y "$backup" 2>/dev/null || stat -f%m "$backup" 2>/dev/null)
            if [[ $backup_date -lt $cutoff_date ]]; then
                if rm -rf "$backup" 2>/dev/null; then
                    log_info "Removed old backup: $backup"
                    cleaned_count=$((cleaned_count + 1))
                else
                    log_error "Failed to remove old backup: $backup"
                fi
            fi
        fi
    done
    
    if [[ $cleaned_count -gt 0 ]]; then
        success "Cleaned $cleaned_count old backups"
    else
        info "No old backups to clean"
    fi
}

# Silent version of clean_old_backups (no user output)
clean_old_backups_silent() {
    local backup_dir="$TOOLBOX_BACKUP_DIR"
    local retention_days="$TOOLBOX_BACKUP_RETENTION"
    
    if [[ ! -d "$backup_dir" ]]; then
        return 0
    fi
    
    local cutoff_date=$(date -d "$retention_days days ago" +%s 2>/dev/null || date -v-${retention_days}d +%s 2>/dev/null)
    
    find "$backup_dir" -maxdepth 1 -type f -o -type d | while read -r backup; do
        if [[ "$backup" != "$backup_dir" ]]; then
            local backup_date=$(stat -c%Y "$backup" 2>/dev/null || stat -f%m "$backup" 2>/dev/null)
            if [[ $backup_date -lt $cutoff_date ]]; then
                rm -rf "$backup" 2>/dev/null
            fi
        fi
    done
}

# Get backup information
backup_info() {
    local backup_path="$1"
    
    if [[ ! -e "$backup_path" ]]; then
        log_error "Backup not found: $backup_path"
        return 1
    fi
    
    info "Backup information:"
    echo "  Path: $backup_path"
    echo "  Type: $(if [[ -d "$backup_path" ]]; then echo "Directory"; else echo "File"; fi)"
    echo "  Size: $(du -sh "$backup_path" | cut -f1)"
    echo "  Created: $(stat -c%y "$backup_path" 2>/dev/null || stat -f%Sm "$backup_path" 2>/dev/null)"
    echo "  Permissions: $(stat -c%a "$backup_path" 2>/dev/null || stat -f%Lp "$backup_path" 2>/dev/null)"
    
    if [[ -d "$backup_path" ]]; then
        local file_count=$(find "$backup_path" -type f | wc -l)
        local dir_count=$(find "$backup_path" -type d | wc -l)
        echo "  Files: $file_count"
        echo "  Directories: $dir_count"
    fi
}

# Backup statistics
backup_stats() {
    local backup_dir="$TOOLBOX_BACKUP_DIR"
    
    if [[ ! -d "$backup_dir" ]]; then
        warn "No backup directory found"
        return 1
    fi
    
    info "Backup statistics:"
    echo "  Directory: $backup_dir"
    echo "  Total size: $(du -sh "$backup_dir" | cut -f1)"
    
    local total_backups=$(find "$backup_dir" -maxdepth 1 -type f -o -type d | grep -v "^$backup_dir$" | wc -l)
    echo "  Total backups: $total_backups"
    
    local file_backups=$(find "$backup_dir" -maxdepth 1 -type f | wc -l)
    local dir_backups=$(find "$backup_dir" -maxdepth 1 -type d | grep -v "^$backup_dir$" | wc -l)
    echo "  File backups: $file_backups"
    echo "  Directory backups: $dir_backups"
    
    echo "  Retention policy: $TOOLBOX_BACKUP_RETENTION days"
    echo "  Auto-backup: $TOOLBOX_AUTO_BACKUP"
}

# Initialize backup system
init_backup() {
    local backup_dir="$TOOLBOX_BACKUP_DIR"
    
    mkdir -p "$backup_dir"
    
    # Log initialization (only if not suppressed)
    if [[ "$TOOLBOX_SUPPRESS_INIT" != "true" ]]; then
        log_info "Backup system initialized"
        log_info "Backup directory: $backup_dir"
        log_info "Retention policy: $TOOLBOX_BACKUP_RETENTION days"
    fi
    
    # Clean old backups on initialization (silently if suppressed)
    if [[ "$TOOLBOX_SUPPRESS_INIT" == "true" ]]; then
        clean_old_backups_silent
    else
        clean_old_backups
    fi
} 