#!/usr/bin/env bash

update_item() {
  local target="$1"
  local action="$2"

  if [[ -z "$target" || "$target" == "-h" || "$target" == "--help" ]]; then
    info "Usage: toolbox update <file> [action]"
    info "Actions: touch (update timestamp), backup (create backup)"
    return
  fi

  if [[ ! -e "$target" ]]; then
    error "File not found: $target"
    return 1
  fi

  case "$action" in
    "touch"|"")
      touch "$target"
      success "Updated timestamp for $target"
      ;;
    "backup")
      local backup_file="${target}.backup.$(date +%Y%m%d_%H%M%S)"
      if cp "$target" "$backup_file"; then
        success "Created backup: $backup_file"
      else
        error "Failed to create backup"
        return 1
      fi
      ;;
    *)
      error "Unknown action: $action"
      info "Available actions: touch, backup"
      return 1
      ;;
  esac
}
