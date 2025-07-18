#!/usr/bin/env bash

compress_item() {
  local source="$1"
  local format="$2"
  local options="$3"

  if [[ -z "$source" || "$source" == "-h" || "$source" == "--help" ]]; then
    info "Usage: toolbox compress <source> [format] [options]"
    info "Formats: gz, bz2, xz, zip, tar.gz, tar.bz2, tar.xz"
    info "Options: -q (quiet), -v (verbose), -f (force overwrite)"
    info "Examples:"
    info "  toolbox compress file.txt"
    info "  toolbox compress folder/ gz"
    info "  toolbox compress data/ tar.gz -v"
    return
  fi

  if [[ ! -e "$source" ]]; then
    error "Source not found: $source"
    return 1
  fi

  # Auto-detect format if not specified
  if [[ -z "$format" ]]; then
    if [[ -f "$source" ]]; then
      format="gz"
    else
      format="tar.gz"
    fi
  fi

  local output_file=""
  local compress_cmd=""

  case "$format" in
    "gz"|"gzip")
      if [[ -f "$source" ]]; then
        output_file="${source}.gz"
        compress_cmd="gzip"
      else
        output_file="${source}.tar.gz"
        compress_cmd="tar -czf"
      fi
      ;;
    "bz2"|"bzip2")
      if [[ -f "$source" ]]; then
        output_file="${source}.bz2"
        compress_cmd="bzip2"
      else
        output_file="${source}.tar.bz2"
        compress_cmd="tar -cjf"
      fi
      ;;
    "xz")
      if [[ -f "$source" ]]; then
        output_file="${source}.xz"
        compress_cmd="xz"
      else
        output_file="${source}.tar.xz"
        compress_cmd="tar -cJf"
      fi
      ;;
    "zip")
      output_file="${source}.zip"
      compress_cmd="zip -r"
      ;;
    "tar.gz"|"tgz")
      output_file="${source}.tar.gz"
      compress_cmd="tar -czf"
      ;;
    "tar.bz2"|"tbz2")
      output_file="${source}.tar.bz2"
      compress_cmd="tar -cjf"
      ;;
    "tar.xz"|"txz")
      output_file="${source}.tar.xz"
      compress_cmd="tar -cJf"
      ;;
    *)
      error "Unknown format: $format"
      info "Available formats: gz, bz2, xz, zip, tar.gz, tar.bz2, tar.xz"
      return 1
      ;;
  esac

  # Check if output file already exists
  if [[ -e "$output_file" && "$options" != *"-f"* ]]; then
    error "Output file already exists: $output_file"
    info "Use -f option to force overwrite"
    return 1
  fi

  # Build command with options
  local cmd="$compress_cmd"
  if [[ "$options" == *"-v"* ]]; then
    cmd="$cmd -v"
  fi
  if [[ "$options" == *"-q"* ]]; then
    cmd="$cmd -q"
  fi

  info "Compressing $source to $output_file"
  
  if eval "$cmd" "$output_file" "$source" 2>/dev/null; then
    success "Compressed $source to $output_file"
    
    # Show compression stats
    if [[ "$options" != *"-q"* ]]; then
      local original_size=$(du -sh "$source" | cut -f1)
      local compressed_size=$(du -sh "$output_file" | cut -f1)
      size "Original: $original_size, Compressed: $compressed_size"
    fi
  else
    error "Failed to compress $source"
    return 1
  fi
} 