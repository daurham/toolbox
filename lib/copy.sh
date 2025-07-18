#!/usr/bin/env bash

copy_item() {
  local source="$1"
  local destination="$2"
  local options="$3"

  if [[ -z "$source" || "$source" == "-h" || "$source" == "--help" ]]; then
    info "Usage: toolbox copy <source> <destination> [options]"
    info "Options: -r (recursive for directories)"
    return
  fi

  if [[ -z "$destination" ]]; then
    error "Destination required"
    info "Usage: toolbox copy <source> <destination> [options]"
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

  local cp_options=""
  if [[ "$options" == "-r" ]] || [[ -d "$source" ]]; then
    cp_options="-r"
  fi

  if cp $cp_options "$source" "$destination"; then
    if [[ -d "$source" ]]; then
      dir "Copied directory $source to $destination"
    else
      file "Copied $source to $destination"
    fi
  else
    error "Failed to copy $source to $destination"
    return 1
  fi
} 