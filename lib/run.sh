#!/usr/bin/env bash

run_command() {
  local target="$1"
  local options="$2"

  if [[ -z "$target" || "$target" == "-h" || "$target" == "--help" ]]; then
    info "Usage: toolbox run <file or command> [options]"
    info "Options: -b (background), -d (detached), -m (monitor), -k (kill on exit)"
    info "Examples:"
    info "  toolbox run script.js"
    info "  toolbox run server.py -b"
    info "  toolbox run 'npm start'"
    info "  toolbox run app.sh -m"
    return
  fi

  # Check if it's a file path
  if [[ -f "$target" ]]; then
    run_file "$target" "$options"
  else
    # Treat as a command
    run_raw_command "$target" "$options"
  fi
}

run_file() {
  local file="$1"
  local options="$2"
  
  # Get file extension and detect type
  local extension="${file##*.}"
  local filename=$(basename "$file")
  local file_type=""
  local interpreter=""
  local run_args=""

  # Detect file type and set appropriate interpreter
  case "$extension" in
    "js"|"mjs"|"cjs")
      file_type="JavaScript"
      interpreter="node"
      ;;
    "ts"|"tsx")
      file_type="TypeScript"
      interpreter="ts-node"
      ;;
    "py"|"py3")
      file_type="Python"
      interpreter="python3"
      ;;
    "py2")
      file_type="Python 2"
      interpreter="python2"
      ;;
    "sh"|"bash")
      file_type="Bash"
      interpreter="bash"
      ;;
    "zsh")
      file_type="Zsh"
      interpreter="zsh"
      ;;
    "rb")
      file_type="Ruby"
      interpreter="ruby"
      ;;
    "php")
      file_type="PHP"
      interpreter="php"
      ;;
    "pl")
      file_type="Perl"
      interpreter="perl"
      ;;
    "java")
      file_type="Java"
      interpreter="java"
      run_args="-cp ."
      ;;
    "cs")
      file_type="C#"
      interpreter="dotnet"
      run_args="run"
      ;;
    "go")
      file_type="Go"
      interpreter="go"
      run_args="run"
      ;;
    "rs")
      file_type="Rust"
      interpreter="cargo"
      run_args="run"
      ;;
    "swift")
      file_type="Swift"
      interpreter="swift"
      ;;
    "kt")
      file_type="Kotlin"
      interpreter="kotlin"
      ;;
    "scala")
      file_type="Scala"
      interpreter="scala"
      ;;
    "r")
      file_type="R"
      interpreter="Rscript"
      ;;
    "m"|"mm")
      file_type="Objective-C"
      interpreter="clang"
      ;;
    "cpp"|"cc"|"cxx")
      file_type="C++"
      interpreter="g++"
      run_args="-o ${file%.*} && ./${file%.*}"
      ;;
    "c")
      file_type="C"
      interpreter="gcc"
      run_args="-o ${file%.*} && ./${file%.*}"
      ;;
    "hs")
      file_type="Haskell"
      interpreter="runhaskell"
      ;;
    "ml")
      file_type="OCaml"
      interpreter="ocaml"
      ;;
    "clj")
      file_type="Clojure"
      interpreter="clojure"
      ;;
    "exs")
      file_type="Elixir"
      interpreter="elixir"
      ;;
    "erl")
      file_type="Erlang"
      interpreter="erl"
      ;;
    "lua")
      file_type="Lua"
      interpreter="lua"
      ;;
    "tcl")
      file_type="Tcl"
      interpreter="tclsh"
      ;;
    "awk")
      file_type="AWK"
      interpreter="awk"
      ;;
    "sed")
      file_type="Sed"
      interpreter="sed"
      ;;
    *)
      # Check shebang line for interpreter
      local shebang=$(head -n 1 "$file" 2>/dev/null)
      if [[ "$shebang" =~ ^#! ]]; then
        interpreter=$(echo "$shebang" | sed 's/^#!//' | awk '{print $1}')
        file_type="Script ($interpreter)"
      else
        error "Unknown file type: $extension"
        info "Supported types: js, ts, py, sh, rb, php, java, cs, go, rs, swift, kt, scala, r, c, cpp, hs, ml, clj, exs, erl, lua, tcl, awk, sed"
        return 1
      fi
      ;;
  esac

  # Check if interpreter is available
  if ! command -v "$interpreter" &> /dev/null; then
    error "$file_type interpreter '$interpreter' not found"
    info "Please install $file_type runtime"
    return 1
  fi

  # Build the command
  local cmd=""
  if [[ -n "$run_args" ]]; then
    cmd="$interpreter $run_args $file"
  else
    cmd="$interpreter $file"
  fi

  info "Running $file_type file: $filename"
  info "Using interpreter: $interpreter"
  
  # Execute with the appropriate mode
  execute_command "$cmd" "$options"
}

run_raw_command() {
  local command="$1"
  local options="$2"

  # Check if command exists
  local cmd_name=$(echo "$command" | awk '{print $1}')
  if ! command -v "$cmd_name" &> /dev/null; then
    warn "Command '$cmd_name' not found in PATH"
  fi

  info "Running command: $command"
  execute_command "$command" "$options"
}

execute_command() {
  local command="$1"
  local options="$2"

  # Handle different run modes
  if [[ "$options" == *"-d"* ]]; then
    # Detached mode - run in background with nohup
    info "Running in detached mode"
    nohup $command > /dev/null 2>&1 &
    local pid=$!
    echo $pid > ".toolbox_run_$pid.pid"
    success "Started detached process (PID: $pid)"
    info "PID saved to .toolbox_run_$pid.pid"
    
  elif [[ "$options" == *"-b"* ]]; then
    # Background mode - run in background
    info "Running in background mode"
    $command &
    local pid=$!
    success "Started background process (PID: $pid)"
    
  elif [[ "$options" == *"-m"* ]]; then
    # Monitor mode - run with monitoring
    info "Running with monitoring"
    echo "Press Ctrl+C to stop monitoring"
    echo "----------------------------------------"
    $command &
    local pid=$!
    echo $pid > ".toolbox_monitor_$pid.pid"
    
    # Monitor the process
    while kill -0 $pid 2>/dev/null; do
      local mem_usage=$(ps -o rss= -p $pid 2>/dev/null | awk '{print $1/1024 " MB"}')
      local cpu_usage=$(ps -o %cpu= -p $pid 2>/dev/null)
      echo -e "\r${CYAN}Monitoring PID $pid - CPU: ${cpu_usage}% - Memory: ${mem_usage}${RESET}"
      sleep 2
    done
    
    rm -f ".toolbox_monitor_$pid.pid"
    success "Process completed"
    
  else
    # Normal mode - run in foreground
    echo "----------------------------------------"
    if [[ "$options" == *"-k"* ]]; then
      # Kill on exit mode
      trap 'echo ""; warn "Process interrupted"; exit 1' INT
    fi
    
    eval $command
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
      success "Command completed successfully"
    else
      error "Command failed with exit code $exit_code"
      return $exit_code
    fi
  fi
}

# Helper function to list running processes
list_running() {
  echo -e "${BLUE}📋 Running Toolbox Processes${RESET}"
  echo -e "${GRAY}================================${RESET}"
  
  local found=false
  
  # Check for PID files
  for pid_file in .toolbox_run_*.pid .toolbox_monitor_*.pid; do
    if [[ -f "$pid_file" ]]; then
      local pid=$(cat "$pid_file")
      local process_name=$(ps -p $pid -o comm= 2>/dev/null)
      local status=""
      
      if kill -0 $pid 2>/dev/null; then
        status="${GREEN}Running${RESET}"
        local mem_usage=$(ps -o rss= -p $pid 2>/dev/null | awk '{print $1/1024 " MB"}')
        local cpu_usage=$(ps -o %cpu= -p $pid 2>/dev/null)
        echo -e "  ${CYAN}PID $pid${RESET} - $process_name - $status - CPU: ${cpu_usage}% - Memory: ${mem_usage}"
      else
        status="${RED}Stopped${RESET}"
        echo -e "  ${CYAN}PID $pid${RESET} - $process_name - $status"
        rm -f "$pid_file"
      fi
      found=true
    fi
  done
  
  if [[ "$found" == "false" ]]; then
    info "No toolbox processes found"
  fi
  
  echo -e "${GRAY}================================${RESET}"
}

# Helper function to kill running processes
kill_running() {
  local pid="$1"
  
  if [[ -z "$pid" ]]; then
    error "PID required"
    info "Usage: toolbox run kill <pid>"
    return 1
  fi
  
  if kill -0 $pid 2>/dev/null; then
    info "Killing process $pid"
    kill $pid
    
    # Wait a moment then check if it's still running
    sleep 1
    if kill -0 $pid 2>/dev/null; then
      warn "Process still running, force killing"
      kill -9 $pid
    fi
    
    success "Process $pid killed"
    
    # Remove PID file if it exists
    rm -f ".toolbox_run_$pid.pid" ".toolbox_monitor_$pid.pid"
  else
    error "Process $pid not found"
    return 1
  fi
} 