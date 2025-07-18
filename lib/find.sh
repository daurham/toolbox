#!/usr/bin/env bash

find_files() {
  local pattern="$1"
  local path="${2:-.}"

  if [[ -z "$pattern" || "$pattern" == "-h" || "$pattern" == "--help" ]]; then
    info "Usage: toolbox find <pattern> [path]"
    info "Examples: toolbox find '*.txt', toolbox find 'file*' /path"
    return
  fi

  if [[ ! -d "$path" ]]; then
    error "Path not found: $path"
    return 1
  fi

  info "Searching for ${CYAN}'$pattern'${RESET} in ${CYAN}$path${RESET}"
  echo ""
  
  local found_files=()
  while IFS= read -r -d '' file; do
    found_files+=("$file")
    file "  $file"
  done < <(find "$path" -name "$pattern" -type f -print0 2>/dev/null)

  local count=${#found_files[@]}
  if [[ $count -eq 0 ]]; then
    warn "No files found matching '$pattern'"
  else
    success "Found $count file(s)"
  fi
} 