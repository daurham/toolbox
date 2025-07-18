#!/usr/bin/env bash

show_help() {
  echo -e "${BLUE}Toolbox: your terminal assistant 🧰${RESET}"
  echo
  echo -e "${GREEN}Usage:${RESET} toolbox <command> [args]"
  echo
  echo -e "${YELLOW}Commands:${RESET}"
  # CRUD
  echo -e "  create <file>     Create file or directory structure"
  echo -e "  create -a <type> <name> Create app (vite, t3, svelte, react, next, vue, etc.)"
  echo -e "  read <file>       Print file contents"
  echo -e "  update <file>     Update file timestamp or create backup"
  echo -e "  delete <target>   Delete a file or directory"

  echo -e "  find <pattern>    Search for files matching pattern"
  echo -e "  list              List files in current directory"
  echo -e "  info <file>       Show file information"
  echo -e "  rename <old> <new> Rename a file or directory"
  echo -e "  size <file>       Get file size"

  echo -e "  move <source> <destination> Move a file or directory"
  echo -e "  copy <source> <destination> Copy a file or directory"
  echo -e "  compress <file>   Compress a file or directory"
  echo -e "  extract <file>    Extract a compressed file"

  # Help
  echo -e "  help              Show this help menu"

  echo
  echo -e "${CYAN}App Types:${RESET} vite, t3, svelte, react, next, vue, nuxt, angular, gatsby, astro"
  echo
}
