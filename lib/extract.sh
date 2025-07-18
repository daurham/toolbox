#!/usr/bin/env bash

extract_item() {
  local archive="$1"
  local destination="$2"
  local options="$3"

  if [[ -z "$archive" || "$archive" == "-h" || "$archive" == "--help" ]]; then
    info "Usage: toolbox extract <archive> [destination] [options]"
    info "Supported formats: .gz, .bz2, .xz, .zip, .tar.gz, .tar.bz2, .tar.xz, .rar, .7z"
    info "Options: -v (verbose), -q (quiet), -f (force overwrite)"
    info "Examples:"
    info "  toolbox extract archive.zip"
    info "  toolbox extract data.tar.gz /path/to/extract"
    info "  toolbox extract file.gz -v"
    return
  fi

  if [[ ! -e "$archive" ]]; then
    error "Archive not found: $archive"
    return 1
  fi

  # Auto-detect format from file extension
  local format=""
  case "$archive" in
    *.gz)
      if [[ "$archive" == *.tar.gz ]]; then
        format="tar.gz"
      else
        format="gz"
      fi
      ;;
    *.bz2)
      if [[ "$archive" == *.tar.bz2 ]]; then
        format="tar.bz2"
      else
        format="bz2"
      fi
      ;;
    *.xz)
      if [[ "$archive" == *.tar.xz ]]; then
        format="tar.xz"
      else
        format="xz"
      fi
      ;;
    *.zip) format="zip" ;;
    *.tar) format="tar" ;;
    *.rar) format="rar" ;;
    *.7z) format="7z" ;;
    *.tgz) format="tar.gz" ;;
    *.tbz2) format="tar.bz2" ;;
    *.txz) format="tar.xz" ;;
    *)
      error "Unknown archive format: $archive"
      info "Supported formats: .gz, .bz2, .xz, .zip, .tar.gz, .tar.bz2, .tar.xz, .rar, .7z"
      return 1
      ;;
  esac

  # Set destination if not provided
  if [[ -z "$destination" ]]; then
    destination="."
  fi

  # Create destination directory if it doesn't exist
  if [[ ! -d "$destination" ]]; then
    mkdir -p "$destination"
  fi

  local extract_cmd=""
  local extract_args=""

  case "$format" in
    "gz")
      extract_cmd="gunzip"
      extract_args="-k"
      ;;
    "bz2")
      extract_cmd="bunzip2"
      extract_args="-k"
      ;;
    "xz")
      extract_cmd="unxz"
      extract_args="-k"
      ;;
    "zip")
      extract_cmd="unzip"
      extract_args="-o"
      ;;
    "tar"|"tar.gz"|"tar.bz2"|"tar.xz")
      extract_cmd="tar"
      extract_args="-xf"
      ;;
    "rar")
      extract_cmd="unrar"
      extract_args="x"
      ;;
    "7z")
      extract_cmd="7z"
      extract_args="x"
      ;;
  esac

  # Add options
  if [[ "$options" == *"-v"* ]]; then
    extract_args="$extract_args -v"
  fi
  if [[ "$options" == *"-q"* ]]; then
    extract_args="$extract_args -q"
  fi
  if [[ "$options" == *"-f"* ]]; then
    extract_args="$extract_args -f"
  fi

  info "Extracting $archive to $destination"

  # Change to destination directory for extraction
  local original_dir=$(pwd)
  cd "$destination"

  if eval "$extract_cmd" $extract_args "$original_dir/$archive" 2>/dev/null; then
    success "Extracted $archive to $destination"
    
    # Show extraction stats
    if [[ "$options" != *"-q"* ]]; then
      local extracted_size=$(du -sh . | cut -f1)
      size "Extracted size: $extracted_size"
    fi
  else
    error "Failed to extract $archive"
    cd "$original_dir"
    return 1
  fi

  cd "$original_dir"
} 