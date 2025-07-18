#!/usr/bin/env bash

list_items() {
  local target="${1:-.}"
  local options="$2"

  if [[ "$target" == "-h" || "$target" == "--help" ]]; then
    info "Usage: toolbox list [path] [options]"
    info "Options: -a (all files), -l (long format), -t (tree view)"
    return
  fi

  if [[ ! -e "$target" ]]; then
    error "Path not found: $target"
    return 1
  fi

  if [[ -d "$target" ]]; then
    info "Listing contents of: ${CYAN}$target${RESET}"
    echo ""
    if [[ "$options" == "-l" ]]; then
      ls -la "$target" | while read -r line; do
        if [[ "$line" =~ ^d ]]; then
          dir "$line"
        elif [[ "$line" =~ ^- ]]; then
          file "$line"
        else
          echo -e "${GRAY}$line${RESET}"
        fi
      done
    elif [[ "$options" == "-a" ]]; then
      ls -a "$target" | while read -r item; do
        if [[ "$item" == "." || "$item" == ".." ]]; then
          echo -e "${GRAY}$item${RESET}"
        elif [[ -d "$target/$item" ]]; then
          dir "$item/"
        else
          file "$item"
        fi
      done
    elif [[ "$options" == "-t" ]]; then
      tree "$target" 2>/dev/null || ls -R "$target"
    else
      ls "$target" | while read -r item; do
        if [[ -d "$target/$item" ]]; then
          dir "$item/"
        else
          file "$item"
        fi
      done
    fi
  else
    file "File: $target"
    ls -la "$target"
  fi
} 