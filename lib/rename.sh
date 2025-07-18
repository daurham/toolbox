#!/usr/bin/env bash

rename_item() {
  local target="$1"
  local new_name="$2"

  if [[ -z "$target" || "$target" == "-h" || "$target" == "--help" ]]; then
    info "Usage: toolbox rename <target> <new_name>"
    return
  fi

  if [[ -z "$new_name" ]]; then
    error "New name required"
    info "Usage: toolbox rename <target> <new_name>"
    return 1
  fi

  if [[ ! -e "$target" ]]; then
    error "Target not found: $target"
    return 1
  fi

  local dir_path="$(dirname "$target")"
  local new_path="$dir_path/$new_name"

  if [[ -e "$new_path" ]]; then
    error "Destination already exists: $new_path"
    return 1
  fi

  if mv "$target" "$new_path"; then
    success "Renamed $target to $new_name"
  else
    error "Failed to rename $target"
    return 1
  fi
} 