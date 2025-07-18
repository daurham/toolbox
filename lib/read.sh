#!/usr/bin/env bash

read_file() {
  local target="$1"

  if [[ -z "$target" || "$target" == "-h" || "$target" == "--help" ]]; then
    info "Usage: toolbox read <file>"
    return
  fi

  if [[ ! -f "$target" ]]; then
    error "File not found: $target"
    return 1
  fi

  cat "$target"
}
