#!/usr/bin/env bash

# Interactive Mode for Toolbox
# Provides guided, user-friendly interface

interactive_main() {
    local current_dir="$PWD"
    
    # Clear screen and show welcome
    clear
    show_welcome
    
    # Main interactive loop
    while true; do
        show_prompt "$current_dir"
        read -e -p "toolbox> " input
        
        # Handle special commands
        case "$input" in
            exit|quit|q) 
                success "Goodbye! 👋"
                exit 0
                ;;
            help|h) 
                show_interactive_help
                ;;
            clear|c) 
                clear
                ;;
            pwd) 
                info "Current directory: $current_dir"
                ;;
            ls|list) 
                interactive_list "$current_dir"
                ;;
            cd) 
                current_dir=$(interactive_cd "$current_dir")
                ;;
            "") 
                continue
                ;;
            *) 
                # Try to execute as regular toolbox command
                execute_toolbox_command "$input"
                ;;
        esac
        
        echo ""
    done
}

show_welcome() {
    echo -e "${BLUE}🛠️  Toolbox Interactive Mode${RESET}"
    echo -e "${GRAY}================================${RESET}"
    echo -e "${WHITE}Welcome to the interactive toolbox!${RESET}"
    echo ""
    echo -e "Quick commands:"
    echo -e "  ${CYAN}help${RESET}     - Show available commands"
    echo -e "  ${CYAN}list${RESET}     - Browse current directory"
    echo -e "  ${CYAN}cd${RESET}       - Change directory"
    echo -e "  ${CYAN}clear${RESET}    - Clear screen"
    echo -e "  ${CYAN}exit${RESET}     - Quit interactive mode"
    echo ""
    echo -e "Or type any toolbox command directly!"
    echo -e "${GRAY}================================${RESET}"
    echo ""
}

show_prompt() {
    local dir="$1"
    local short_dir=$(basename "$dir")
    if [[ "$dir" == "$HOME" ]]; then
        short_dir="~"
    elif [[ "$dir" == "$HOME"/* ]]; then
        short_dir="~/${dir#$HOME/}"
    fi
    
    echo -e "${GREEN}📁 $short_dir${RESET}"
}

show_interactive_help() {
    echo -e "${BLUE}📚 Interactive Mode Help${RESET}"
    echo -e "${GRAY}================================${RESET}"
    echo ""
    echo -e "${WHITE}Navigation:${RESET}"
    echo -e "  ${CYAN}list${RESET} or ${CYAN}ls${RESET}     - Browse current directory"
    echo -e "  ${CYAN}cd${RESET}              - Change directory"
    echo -e "  ${CYAN}pwd${RESET}             - Show current directory"
    echo ""
    echo -e "${WHITE}File Operations:${RESET}"
    echo -e "  ${CYAN}create <name>${RESET}   - Create file/directory"
    echo -e "  ${CYAN}read <file>${RESET}     - Read file contents"
    echo -e "  ${CYAN}delete <name>${RESET}   - Delete file/directory"
    echo -e "  ${CYAN}copy <src> <dest>${RESET} - Copy files"
    echo -e "  ${CYAN}move <src> <dest>${RESET} - Move files"
    echo ""
    echo -e "${WHITE}Search & Info:${RESET}"
    echo -e "  ${CYAN}find <pattern>${RESET}  - Find files"
    echo -e "  ${CYAN}size <path>${RESET}     - Get file size"
    echo -e "  ${CYAN}info <path>${RESET}     - Get detailed info"
    echo ""
    echo -e "${WHITE}System:${RESET}"
    echo -e "  ${CYAN}ports${RESET}           - Check open ports"
    echo -e "  ${CYAN}run <script>${RESET}    - Execute script"
    echo ""
    echo -e "${WHITE}Utilities:${RESET}"
    echo -e "  ${CYAN}compress <file>${RESET} - Compress files"
    echo -e "  ${CYAN}extract <archive>${RESET} - Extract archives"
    echo ""
    echo -e "${YELLOW}💡 Tip: You can also use regular toolbox commands directly!${RESET}"
}

interactive_list() {
    local dir="$1"
    
    if [[ ! -d "$dir" ]]; then
        error "Directory not found: $dir"
        return 1
    fi
    
    echo -e "${BLUE}📁 Contents of $dir:${RESET}"
    echo -e "${GRAY}================================${RESET}"
    
    local items=()
    local item_types=()
    local counter=1
    
    # Collect items
    while IFS= read -r -d '' item; do
        local name=$(basename "$item")
        local type=""
        
        if [[ -d "$item" ]]; then
            type="dir"
            items+=("$name")
            item_types+=("dir")
        elif [[ -f "$item" ]]; then
            type="file"
            items+=("$name")
            item_types+=("file")
        fi
    done < <(find "$dir" -maxdepth 1 -mindepth 1 -print0 | sort -z)
    
    # Display items
    for i in "${!items[@]}"; do
        local item="${items[$i]}"
        local type="${item_types[$i]}"
        
        if [[ "$type" == "dir" ]]; then
            echo -e "  ${counter}. ${MAGENTA}📁 $item${RESET}"
        else
            local size=$(du -h "$dir/$item" 2>/dev/null | cut -f1)
            echo -e "  ${counter}. ${CYAN}📄 $item${RESET} (${YELLOW}$size${RESET})"
        fi
        counter=$((counter + 1))
    done
    
    if [[ ${#items[@]} -eq 0 ]]; then
        echo -e "  ${GRAY}(empty directory)${RESET}"
    fi
    
    echo ""
    show_list_actions "$dir"
}

show_list_actions() {
    local dir="$1"
    
    echo -e "${WHITE}Actions:${RESET}"
    echo -e "  ${CYAN}create${RESET} - Create new file/directory"
    echo -e "  ${CYAN}cd${RESET}     - Change directory"
    echo -e "  ${CYAN}back${RESET}   - Go back to main menu"
    echo ""
}

interactive_cd() {
    local current_dir="$1"
    
    echo -e "${BLUE}📁 Change Directory${RESET}"
    echo -e "Current: $current_dir"
    echo -e "Enter new path (or 'back' to cancel):"
    read -e -p "Path: " new_path
    
    case "$new_path" in
        back|b|"") 
            echo "$current_dir"
            ;;
        ~*) 
            # Expand tilde
            new_path="${new_path/#\~/$HOME}"
            if [[ -d "$new_path" ]]; then
                success "Changed to: $new_path"
                echo "$new_path"
            else
                error "Directory not found: $new_path"
                echo "$current_dir"
            fi
            ;;
        *) 
            # Relative or absolute path
            if [[ -d "$new_path" ]]; then
                success "Changed to: $new_path"
                echo "$new_path"
            elif [[ -d "$current_dir/$new_path" ]]; then
                local full_path="$current_dir/$new_path"
                success "Changed to: $full_path"
                echo "$full_path"
            else
                error "Directory not found: $new_path"
                echo "$current_dir"
            fi
            ;;
    esac
}

execute_toolbox_command() {
    local command="$1"
    
    # Execute the command through the main toolbox
    "$TOOLBOX_ROOT/bin/toolbox" $command
    
    if [[ $? -eq 0 ]]; then
        success "Command completed successfully"
    else
        error "Command failed"
    fi
}

# Guided wizards for complex operations
wizard_compress() {
    echo -e "${BLUE}📦 Compression Wizard${RESET}"
    echo -e "${GRAY}================================${RESET}"
    
    read -e -p "Enter file/directory to compress: " target
    
    if [[ ! -e "$target" ]]; then
        error "File/directory not found: $target"
        return 1
    fi
    
    echo -e "Compression format:"
    echo -e "  1. tar.gz (recommended)"
    echo -e "  2. zip"
    echo -e "  3. 7z"
    read -p "Choose format (1-3): " format_choice
    
    case "$format_choice" in
        1) format="tar.gz" ;;
        2) format="zip" ;;
        3) format="7z" ;;
        *) format="tar.gz" ;;
    esac
    
    read -p "Compression level (1-9, default 6): " level
    level=${level:-6}
    
    echo -e "${YELLOW}Compressing $target with $format (level $level)...${RESET}"
    "$TOOLBOX_ROOT/bin/toolbox" compress "$target" --format "$format" --level "$level"
}

wizard_find() {
    echo -e "${BLUE}🔍 Find Wizard${RESET}"
    echo -e "${GRAY}================================${RESET}"
    
    echo -e "What would you like to find?"
    echo -e "  1. Files by name pattern"
    echo -e "  2. Files by content"
    echo -e "  3. Large files"
    echo -e "  4. Recently modified files"
    read -p "Choose option (1-4): " find_type
    
    case "$find_type" in
        1)
            read -e -p "Enter file pattern (e.g., *.log): " pattern
            "$TOOLBOX_ROOT/bin/toolbox" find "$pattern"
            ;;
        2)
            read -e -p "Enter text to search for: " text
            "$TOOLBOX_ROOT/bin/toolbox" find --content "$text"
            ;;
        3)
            read -e -p "Enter minimum size (e.g., 1M, 100K): " size
            "$TOOLBOX_ROOT/bin/toolbox" find --size "+$size"
            ;;
        4)
            read -e -p "Enter days (e.g., 7 for last week): " days
            "$TOOLBOX_ROOT/bin/toolbox" find --modified "+${days}d"
            ;;
        *)
            error "Invalid option"
            ;;
    esac
} 