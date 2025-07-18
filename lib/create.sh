#!/usr/bin/env bash

create_item() {
  local target="$1"

  if [[ -z "$target" || "$target" == "-h" || "$target" == "--help" ]]; then
    info "Usage: toolbox create <file or path> (use trailing / for directories)"
    return
  fi

  # Handle paths starting with / as relative to current directory
  if [[ "$target" == /* ]]; then
    # Remove the leading / to make it relative to current directory
    local relative_target="${target#/}"
    
    # Check if it's a directory (ends with /)
    if [[ "$target" == */ ]]; then
      mkdir -p "$relative_target"
      dir "Created directory $target"
    else
      mkdir -p "$(dirname "$relative_target")"
      touch "$relative_target"
      file "Created $target"
    fi
  else
    # Handle relative paths
    # Check if it's a directory (ends with /)
    if [[ "$target" == */ ]]; then
      mkdir -p "$target"
      dir "Created directory $target"
    else
      mkdir -p "$(dirname "$target")"
      touch "$target"
      file "Created $target"
    fi
  fi
}
