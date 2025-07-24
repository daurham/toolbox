#!/usr/bin/env bash

delete_item() {
  local target="$1"

  if [[ -z "$target" || "$target" == "-h" || "$target" == "--help" ]]; then
    info "Usage: toolbox delete <file or dir>"
    return
  fi

  if [[ -e "$target" ]]; then
    # Auto-backup before deletion
    auto_backup "$target" "delete"
    
    # Confirm deletion if enabled
    if [[ "$TOOLBOX_CONFIRM_DELETE" == "true" ]]; then
      read -p "Are you sure you want to delete '$target'? (y/N): " -n 1 -r
      echo
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Delete cancelled by user: $target"
        return 1
      fi
    fi
    
    if rm -rf "$target"; then
      log_file_op "deleted" "$target"
      success "Deleted $target"
    else
      log_error "Failed to delete: $target"
      error "Failed to delete $target"
      return 1
    fi
  else
    log_error "Delete target does not exist: $target"
    error "Nothing to delete: $target"
    return 1
  fi
}
