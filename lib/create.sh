#!/usr/bin/env bash

create_item() {
  local target="$1"
  local app_type="$2"
  local app_name="$3"

  # Check for app creation flags
  if [[ "$target" == "-a" || "$target" == "-app" || "$target" == "--app" ]]; then
    if [[ -z "$app_type" ]]; then
      info "Usage: toolbox create -a <app-type> <app-name>"
      info "Available app types:"
      info "  vite, t3, svelte, react, next, vue, nuxt, angular, gatsby, astro, csharp"
      info "Examples:"
      info "  toolbox create -a vite my-app"
      info "  toolbox create --app next my-next-app"
      return
    fi
    
    if [[ -z "$app_name" ]]; then
      error "App name required"
      info "Usage: toolbox create -a <app-type> <app-name>"
      return 1
    fi
    
    create_app "$app_type" "$app_name"
    return
  fi

  if [[ -z "$target" || "$target" == "-h" || "$target" == "--help" ]]; then
    info "Usage: toolbox create <file or path> (use trailing / for directories)"
    info "Or: toolbox create -a <app-type> <app-name>"
    info ""
    info "Available app types: vite, t3, svelte, react, next, vue, nuxt, angular, gatsby, astro, csharp"
    return
  fi

  # Handle paths starting with / as relative to current directory
  if [[ "$target" == /* ]]; then
    # Remove the leading / to make it relative to current directory
    local relative_target="${target#/}"
    
    # Check if it's a directory (ends with /)
    if [[ "$target" == */ ]]; then
      mkdir -p "$relative_target"
      dir "Created directory $target"
    else
      mkdir -p "$(dirname "$relative_target")"
      touch "$relative_target"
      file "Created $target"
    fi
  else
    # Handle relative paths
    # Check if it's a directory (ends with /)
    if [[ "$target" == */ ]]; then
      mkdir -p "$target"
      dir "Created directory $target"
    else
      mkdir -p "$(dirname "$target")"
      touch "$target"
      file "Created $target"
    fi
  fi
}

create_app() {
  local app_type="$1"
  local app_name="$2"
  
  # Check if app name already exists
  if [[ -e "$app_name" ]]; then
    error "Directory '$app_name' already exists"
    return 1
  fi
  
  info "Creating $app_type app: $app_name"
  
  case "$app_type" in
    "vite")
      create_vite_app "$app_name"
      ;;
    "t3")
      create_t3_app "$app_name"
      ;;
    "svelte")
      create_svelte_app "$app_name"
      ;;
    "react"|"create-react-app")
      create_react_app "$app_name"
      ;;
    "next")
      create_next_app "$app_name"
      ;;
    "vue")
      create_vue_app "$app_name"
      ;;
    "nuxt")
      create_nuxt_app "$app_name"
      ;;
    "angular")
      create_angular_app "$app_name"
      ;;
    "gatsby")
      create_gatsby_app "$app_name"
      ;;
    "astro")
      create_astro_app "$app_name"
      ;;
    "csharp"|"c#"|"dotnet")
      create_csharp_app "$app_name"
      ;;
    *)
      error "Unknown app type: $app_type"
      info "Available types: vite, t3, svelte, react, next, vue, nuxt, angular, gatsby, astro, csharp"
      return 1
      ;;
  esac
}

create_vite_app() {
  local app_name="$1"
  info "Creating Vite app..."
  
  if command -v npm &> /dev/null; then
    npm create vite@latest "$app_name" -- --template react-ts
    success "Vite app created successfully!"
    info "Next steps:"
    info "  cd $app_name"
    info "  npm install"
    info "  npm run dev"
  else
    error "npm not found. Please install Node.js and npm first."
    return 1
  fi
}

create_t3_app() {
  local app_name="$1"
  info "Creating T3 app..."
  
  if command -v npx &> /dev/null; then
    npx create-t3-app@latest "$app_name"
    success "T3 app created successfully!"
    info "Next steps:"
    info "  cd $app_name"
    info "  npm run dev"
  else
    error "npx not found. Please install Node.js and npm first."
    return 1
  fi
}

create_svelte_app() {
  local app_name="$1"
  info "Creating Svelte app..."
  
  if command -v npm &> /dev/null; then
    npm create svelte@latest "$app_name"
    success "Svelte app created successfully!"
    info "Next steps:"
    info "  cd $app_name"
    info "  npm install"
    info "  npm run dev"
  else
    error "npm not found. Please install Node.js and npm first."
    return 1
  fi
}

create_react_app() {
  local app_name="$1"
  info "Creating React app..."
  
  if command -v npx &> /dev/null; then
    npx create-react-app "$app_name" --template typescript
    success "React app created successfully!"
    info "Next steps:"
    info "  cd $app_name"
    info "  npm start"
  else
    error "npx not found. Please install Node.js and npm first."
    return 1
  fi
}

create_next_app() {
  local app_name="$1"
  info "Creating Next.js app..."
  
  if command -v npx &> /dev/null; then
    npx create-next-app@latest "$app_name" --typescript --tailwind --eslint
    success "Next.js app created successfully!"
    info "Next steps:"
    info "  cd $app_name"
    info "  npm run dev"
  else
    error "npx not found. Please install Node.js and npm first."
    return 1
  fi
}

create_vue_app() {
  local app_name="$1"
  info "Creating Vue app..."
  
  if command -v npm &> /dev/null; then
    npm create vue@latest "$app_name"
    success "Vue app created successfully!"
    info "Next steps:"
    info "  cd $app_name"
    info "  npm install"
    info "  npm run dev"
  else
    error "npm not found. Please install Node.js and npm first."
    return 1
  fi
}

create_nuxt_app() {
  local app_name="$1"
  info "Creating Nuxt app..."
  
  if command -v npx &> /dev/null; then
    npx nuxi@latest init "$app_name"
    success "Nuxt app created successfully!"
    info "Next steps:"
    info "  cd $app_name"
    info "  npm install"
    info "  npm run dev"
  else
    error "npx not found. Please install Node.js and npm first."
    return 1
  fi
}

create_angular_app() {
  local app_name="$1"
  info "Creating Angular app..."
  
  if command -v npx &> /dev/null; then
    npx @angular/cli@latest new "$app_name" --routing --style=css
    success "Angular app created successfully!"
    info "Next steps:"
    info "  cd $app_name"
    info "  npm start"
  else
    error "npx not found. Please install Node.js and npm first."
    return 1
  fi
}

create_gatsby_app() {
  local app_name="$1"
  info "Creating Gatsby app..."
  
  if command -v npx &> /dev/null; then
    npx gatsby@latest new "$app_name"
    success "Gatsby app created successfully!"
    info "Next steps:"
    info "  cd $app_name"
    info "  npm run develop"
  else
    error "npx not found. Please install Node.js and npm first."
    return 1
  fi
}

create_astro_app() {
  local app_name="$1"
  info "Creating Astro app..."
  
  if command -v npm &> /dev/null; then
    npm create astro@latest "$app_name"
    success "Astro app created successfully!"
    info "Next steps:"
    info "  cd $app_name"
    info "  npm run dev"
  else
    error "npm not found. Please install Node.js and npm first."
    return 1
  fi
}

create_csharp_app() {
  local app_name="$1"
  local project_type="${2:-console}"  # Default to console if not specified
  
  info "Creating C# $project_type project: $app_name"
  
  if command -v dotnet &> /dev/null; then
    # Create the project
    if dotnet new "$project_type" -n "$app_name"; then
      success "C# $project_type project created successfully!"
      info "Next steps:"
      info "  cd $app_name"
      info "  dotnet run"
      info ""
      info "Available C# project types:"
      info "  console, web, mvc, webapi, blazorserver, blazorwasm, xunit, nunit"
      info "  classlib, worker, grpc, razor, razorclasslib, mstest"
    else
      error "Failed to create C# project"
      return 1
    fi
  else
    error "dotnet CLI not found. Please install .NET SDK first."
    info "Download from: https://dotnet.microsoft.com/download"
    return 1
  fi
}
