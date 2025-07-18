#!/usr/bin/env bash

TOOLBOX_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB="$TOOLBOX_ROOT/lib"

source "$LIB/utils.sh"

COMMAND="$1"
shift || true

case "$COMMAND" in
# CRUD
  create)   source "$LIB/create.sh";  create_item "$@";;
  read)     source "$LIB/read.sh";    read_file "$@";;
  update)   source "$LIB/update.sh";  update_item "$@";;
  delete)   source "$LIB/delete.sh";  delete_item "$@";;

  find)     source "$LIB/find.sh";    find_files "$@";;
  list)     source "$LIB/list.sh";    list_items "$@";;
  info)     source "$LIB/info.sh";    show_info "$@";;
  rename)   source "$LIB/rename.sh";  rename_item "$@";;
  size)     source "$LIB/size.sh";    get_size "$@";;
  
  move)     source "$LIB/move.sh";    move_item "$@";;
  copy)     source "$LIB/copy.sh";    copy_item "$@";;
  compress) source "$LIB/compress.sh"; compress_item "$@";;
  extract)  source "$LIB/extract.sh";  extract_item "$@";;
  
  run)      source "$LIB/run.sh";     run_command "$@";;
  ports)    source "$LIB/ports.sh";   show_ports "$@";;
  
  # hash)     source "$LIB/hash.sh";    calculate_hash "$@";;
  # encrypt)  source "$LIB/encrypt.sh";  encrypt_item "$@";;
  help)     source "$LIB/help.sh";    show_help "$@";;
  -h|--help|"") source "$LIB/help.sh"; show_help;;
  *) error "Unknown command: $COMMAND"; show_help;;
esac
