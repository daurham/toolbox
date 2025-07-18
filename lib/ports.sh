#!/usr/bin/env bash

show_ports() {
  local port="$1"
  local action="$2"

  if [[ "$port" == "-h" || "$port" == "--help" ]]; then
    info "Usage: toolbox ports [port] [action]"
    info "Actions: kill (kill process on port)"
    info "Examples:"
    info "  toolbox ports"
    info "  toolbox ports 3000"
    info "  toolbox ports 8080 kill"
    return
  fi

  # If no port specified, show all listening ports
  if [[ -z "$port" ]]; then
    show_all_ports
    return
  fi

  # Validate port number
  if ! [[ "$port" =~ ^[0-9]+$ ]] || [[ $port -lt 1 ]] || [[ $port -gt 65535 ]]; then
    error "Invalid port number: $port"
    info "Port must be between 1 and 65535"
    return 1
  fi

  # Check if port is in use
  local port_info=$(get_port_info "$port")
  
  if [[ -z "$port_info" ]]; then
    info "Port $port is not in use"
    return 0
  fi

  # Parse port information
  local pid=$(echo "$port_info" | awk '{print $1}')
  local process=$(echo "$port_info" | awk '{print $2}')
  local user=$(echo "$port_info" | awk '{print $3}')

  echo -e "${BLUE}🔌 Port Information: $port${RESET}"
  echo -e "${GRAY}================================${RESET}"
  echo -e "  ${CYAN}Port:${RESET} $port"
  echo -e "  ${CYAN}PID:${RESET} $pid"
  echo -e "  ${CYAN}Process:${RESET} $process"
  echo -e "  ${CYAN}User:${RESET} $user"

  # Show process details
  local cmd_line=$(ps -p $pid -o cmd= 2>/dev/null)
  if [[ -n "$cmd_line" ]]; then
    echo -e "  ${CYAN}Command:${RESET} $cmd_line"
  fi

  # Show process stats
  local cpu_usage=$(ps -p $pid -o %cpu= 2>/dev/null)
  local mem_usage=$(ps -p $pid -o rss= 2>/dev/null | awk '{print $1/1024 " MB"}')
  echo -e "  ${CYAN}CPU:${RESET} ${cpu_usage}%"
  echo -e "  ${CYAN}Memory:${RESET} ${mem_usage}"

  # Handle kill action
  if [[ "$action" == "kill" ]]; then
    echo ""
    warn "Killing process $pid on port $port"
    if kill -0 $pid 2>/dev/null; then
      kill $pid
      sleep 1
      if kill -0 $pid 2>/dev/null; then
        warn "Process still running, force killing"
        kill -9 $pid
      fi
      success "Process killed"
    else
      error "Process $pid not found"
      return 1
    fi
  fi

  echo -e "${GRAY}================================${RESET}"
}

show_all_ports() {
  echo -e "${BLUE}🔌 Listening Ports${RESET}"
  echo -e "${GRAY}================================${RESET}"
  
  # Get all listening ports
  local ports_info=$(get_all_ports)
  
  if [[ -z "$ports_info" ]]; then
    info "No listening ports found"
    return 0
  fi

  # Display ports in a table format
  echo -e "${CYAN}Port${RESET}    ${CYAN}PID${RESET}    ${CYAN}Process${RESET}    ${CYAN}User${RESET}"
  echo -e "${GRAY}--------------------------------${RESET}"
  
  echo "$ports_info" | while read -r line; do
    if [[ -n "$line" ]]; then
      local port=$(echo "$line" | awk '{print $1}')
      local pid=$(echo "$line" | awk '{print $2}')
      local process=$(echo "$line" | awk '{print $3}')
      local user=$(echo "$line" | awk '{print $4}')
      
      printf "%-8s %-8s %-15s %-10s\n" "$port" "$pid" "$process" "$user"
    fi
  done
  
  echo -e "${GRAY}================================${RESET}"
  info "Use 'toolbox ports <port> kill' to kill a process"
}

get_port_info() {
  local port="$1"
  
  # Try different methods to get port information
  local port_info=""
  
  # Method 1: netstat
  if command -v netstat &> /dev/null; then
    port_info=$(netstat -tlnp 2>/dev/null | grep ":$port " | head -1)
    if [[ -n "$port_info" ]]; then
      local pid=$(echo "$port_info" | awk '{print $7}' | cut -d'/' -f1)
      local process=$(echo "$port_info" | awk '{print $7}' | cut -d'/' -f2)
      local user=$(ps -o user= -p $pid 2>/dev/null)
      echo "$pid $process $user"
      return
    fi
  fi
  
  # Method 2: ss
  if command -v ss &> /dev/null; then
    port_info=$(ss -tlnp 2>/dev/null | grep ":$port " | head -1)
    if [[ -n "$port_info" ]]; then
      local pid=$(echo "$port_info" | awk '{print $6}' | grep -o 'pid=[0-9]*' | cut -d'=' -f2)
      local process=$(echo "$port_info" | awk '{print $6}' | grep -o 'process=[^,]*' | cut -d'=' -f2)
      local user=$(ps -o user= -p $pid 2>/dev/null)
      echo "$pid $process $user"
      return
    fi
  fi
  
  # Method 3: lsof
  if command -v lsof &> /dev/null; then
    port_info=$(lsof -i :$port 2>/dev/null | grep LISTEN | head -1)
    if [[ -n "$port_info" ]]; then
      local pid=$(echo "$port_info" | awk '{print $2}')
      local process=$(echo "$port_info" | awk '{print $1}')
      local user=$(echo "$port_info" | awk '{print $3}')
      echo "$pid $process $user"
      return
    fi
  fi
  
  echo ""
}

get_all_ports() {
  local ports_info=""
  
  # Try different methods to get all ports
  if command -v netstat &> /dev/null; then
    ports_info=$(netstat -tlnp 2>/dev/null | grep LISTEN | awk '{print $4, $7}' | while read -r addr pid_proc; do
      local port=$(echo "$addr" | rev | cut -d':' -f1 | rev)
      local pid=$(echo "$pid_proc" | cut -d'/' -f1)
      local process=$(echo "$pid_proc" | cut -d'/' -f2)
      local user=$(ps -o user= -p $pid 2>/dev/null)
      echo "$port $pid $process $user"
    done)
  elif command -v ss &> /dev/null; then
    ports_info=$(ss -tlnp 2>/dev/null | grep LISTEN | awk '{print $4, $6}' | while read -r addr pid_proc; do
      local port=$(echo "$addr" | rev | cut -d':' -f1 | rev)
      local pid=$(echo "$pid_proc" | grep -o 'pid=[0-9]*' | cut -d'=' -f2)
      local process=$(echo "$pid_proc" | grep -o 'process=[^,]*' | cut -d'=' -f2)
      local user=$(ps -o user= -p $pid 2>/dev/null)
      echo "$port $pid $process $user"
    done)
  elif command -v lsof &> /dev/null; then
    ports_info=$(lsof -i -P -n 2>/dev/null | grep LISTEN | awk '{print $9, $2, $1, $3}' | while read -r addr pid process user; do
      local port=$(echo "$addr" | rev | cut -d':' -f1 | rev)
      echo "$port $pid $process $user"
    done)
  fi
  
  echo "$ports_info" | sort -n | uniq
} 