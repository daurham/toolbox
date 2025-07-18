#!/usr/bin/env bash

delete_item() {
  local target="$1"

  if [[ -z "$target" || "$target" == "-h" || "$target" == "--help" ]]; then
    info "Usage: toolbox delete <file or dir>"
    return
  fi

  if [[ -e "$target" ]]; then
    rm -rf "$target"
    success "Deleted $target"
  else
    error "Nothing to delete: $target"
  fi
}
