#!/usr/bin/env bash

move_item() {
  local source="$1"
  local destination="$2"

  if [[ -z "$source" || "$source" == "-h" || "$source" == "--help" ]]; then
    info "Usage: toolbox move <source> <destination>"
    return
  fi

  if [[ -z "$destination" ]]; then
    error "Destination required"
    info "Usage: toolbox move <source> <destination>"
    return 1
  fi

  if [[ ! -e "$source" ]]; then
    error "Source not found: $source"
    return 1
  fi

  # Create destination directory if it doesn't exist
  if [[ "$destination" == */ ]] || [[ -d "$destination" ]]; then
    mkdir -p "$destination"
  else
    mkdir -p "$(dirname "$destination")"
  fi

  if mv "$source" "$destination"; then
    if [[ -d "$destination" ]]; then
      dir "Moved $source to $destination"
    else
      file "Moved $source to $destination"
    fi
  else
    error "Failed to move $source to $destination"
    return 1
  fi
} 