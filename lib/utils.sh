#!/usr/bin/env bash

# Earthy color palette - semantically matched to usage
GREEN="\033[38;5;108m"      # Forest green - for success/completion (life/growth)
RED="\033[38;5;131m"        # Muted red/brown - for errors (danger/stop)
YELLOW="\033[38;5;179m"     # Warm amber - for warnings and size (attention/measurement)
BLUE="\033[38;5;67m"        # Slate blue - for info messages (knowledge/guidance)
CYAN="\033[38;5;72m"        # Sage green - for files (nature/leaves)
MAGENTA="\033[38;5;95m"     # Muted purple - for directories (earth/soil)
WHITE="\033[38;5;252m"      # Soft white - for headers (clarity)
GRAY="\033[38;5;245m"       # Medium gray - for timestamps (neutral/time)
RESET="\033[0m"

info()    { echo -e "${BLUE}ℹ️  $*${RESET}"; }
success() { echo -e "${GREEN}✅ $*${RESET}"; }
warn()    { echo -e "${YELLOW}⚠️  $*${RESET}"; }
error()   { echo -e "${RED}❌ $*${RESET}" >&2; }
file()    { echo -e "${CYAN}📄 $*${RESET}"; }
dir()     { echo -e "${MAGENTA}📁 $*${RESET}"; }
size()    { echo -e "${YELLOW}📊 $*${RESET}"; }
time_info() { echo -e "${GRAY}🕒 $*${RESET}"; }
