#!/usr/bin/env bash

get_size() {
  local target="${1:-.}"

  if [[ "$target" == "-h" || "$target" == "--help" ]]; then
    info "Usage: toolbox size [file or directory]"
    return
  fi

  if [[ ! -e "$target" ]]; then
    error "Path not found: $target"
    return 1
  fi

  if [[ -f "$target" ]]; then
    local size=$(du -h "$target" | cut -f1)
    file "File: $target"
    size "Size: $size"
  elif [[ -d "$target" ]]; then
    local size=$(du -sh "$target" | cut -f1)
    local count=$(find "$target" -type f | wc -l)
    dir "Directory: $target"
    size "Size: $size"
    info "Files: $count"
  else
    error "Not a file or directory: $target"
    return 1
  fi
} 