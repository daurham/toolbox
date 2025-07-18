#!/usr/bin/env bash

show_info() {
  local target="${1:-.}"

  if [[ "$target" == "-h" || "$target" == "--help" ]]; then
    info "Usage: toolbox info [file or directory]"
    return
  fi

  if [[ ! -e "$target" ]]; then
    error "Path not found: $target"
    return 1
  fi

  echo -e "${WHITE}📁 File Information: ${CYAN}$target${RESET}"
  echo -e "${GRAY}─────────────────────────────────────────${RESET}"
  
  # Function to format timestamp
  format_timestamp() {
    local file="$1"
    local timestamp=$(stat -c %Y "$file" 2>/dev/null)
    if [[ -n "$timestamp" ]]; then
      date -d "@$timestamp" "+%B %d, %Y at %I:%M %p %Z"
    else
      echo "N/A"
    fi
  }
  
  # Basic file info
  if [[ -f "$target" ]]; then
    file "Type: File"
    size "Size: $(du -h "$target" | cut -f1)"
    info "Lines: $(wc -l < "$target" 2>/dev/null || echo "N/A")"
    warn "Permissions: $(ls -la "$target" | awk '{print $1}')"
    info "Owner: $(ls -la "$target" | awk '{print $3}')"
    info "Group: $(ls -la "$target" | awk '{print $4}')"
    time_info "Modified: $(format_timestamp "$target")"
  elif [[ -d "$target" ]]; then
    dir "Type: Directory"
    size "Size: $(du -sh "$target" | cut -f1)"
    info "Files: $(find "$target" -type f | wc -l)"
    dir "Directories: $(find "$target" -type d | wc -l)"
    warn "Permissions: $(ls -ld "$target" | awk '{print $1}')"
    info "Owner: $(ls -ld "$target" | awk '{print $3}')"
    info "Group: $(ls -ld "$target" | awk '{print $4}')"
    time_info "Modified: $(format_timestamp "$target")"
  fi
  
  echo -e "${GRAY}─────────────────────────────────────────${RESET}"
} 