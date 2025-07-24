# 🛠️ Toolbox

> A powerful command-line utility collection for developers

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell: Bash](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Platform: Unix/Linux/GitBash](https://img.shields.io/badge/Platform-Unix%2FLinux%2FGitBash-blue.svg)](https://en.wikipedia.org/wiki/Unix-like)
[![Windows: Git Bash](https://img.shields.io/badge/Windows-Git%20Bash-purple.svg)](https://git-scm.com/download/win)

A comprehensive command-line toolbox that provides essential utilities for file management, system operations, and development tasks. Built with pure Bash for maximum compatibility and performance.

## ✨ New Features (v2.0)

- 🔧 **Configuration System** - Customize behavior with `~/toolbox/config.sh`
- 📝 **Enhanced Logging** - Multi-level logging with file rotation
- 🔄 **Backup System** - Automatic backups with retention policies
- 🛡️ **Safety Features** - Confirmation prompts and auto-backup
- 🎨 **Beautiful Output** - Colored output with emojis and icons

## 📁 Project Structure

```
~/toolbox/
├── 📂 bin/
│   └── 🚀 toolbox           # Entry point (executable CLI)
├── 📂 lib/
│   ├── 🎨 utils.sh          # Colors, icons, logging, help display
│   ├── 🔧 config.sh         # Configuration system
│   ├── 📝 logging.sh        # Enhanced logging system
│   ├── 🔄 backup.sh         # Backup and restore system
│   ├── ⚙️  config_cmd.sh     # Configuration command
│   ├── 📋 logs_cmd.sh       # Logs management command
│   ├── 💾 backup_cmd.sh     # Backup management command
│   ├── ➕ create.sh          # Command: create
│   ├── 📖 read.sh            # Command: read
│   ├── 🗑️  delete.sh          # Command: delete (with auto-backup)
│   ├── 📋 list.sh            # Command: list
│   ├── ✏️  rename.sh          # Command: rename
│   ├── 📁 move.sh            # Command: move
│   ├── 📋 copy.sh            # Command: copy
│   ├── 🔍 find.sh            # Command: find
│   ├── 📊 size.sh            # Command: size
│   ├── 📦 compress.sh        # Command: compress
│   ├── 📦 extract.sh         # Command: extract
│   ├── 🔌 ports.sh           # Command: ports
│   ├── 🏃 run.sh             # Command: run
│   ├── 📝 read.sh            # Command: read
│   ├── 🔄 update.sh          # Command: update
│   └── ❓ help.sh             # Command: help
├── 🧪 tests/                 # Test suite
├── 📋 Makefile               # Build automation
└── 🔧 toolbox.sh             # Dispatch logic for routing commands
```

## 🚀 Quick Start

### Installation

1. **Clone or download the toolbox**
   ```bash
   git clone <repository-url> ~/toolbox
   # or download and extract to ~/toolbox
   ```

2. **Add to your PATH** (in `~/.bashrc` or `~/.zshrc`)
   ```bash
   export PATH="$HOME/toolbox/bin:$PATH"
   ```

3. **Make it executable** (if needed)
   ```bash
   chmod +x ~/toolbox/bin/toolbox
   ```
   > **Note**: Usually not needed if cloning from git, but required if downloading as ZIP

4. **Add aliases** (in `~/.bashrc` or `~/.zshrc`)
   ```bash
   # Toolbox aliases
   if [ -f ~/toolbox/toolbox_aliases ]; then
       . ~/toolbox/toolbox_aliases
   fi
   ```

5. **Reload your shell**
   ```bash
   source ~/.bashrc  # or `source ~/.zshrc`
   ```

6. **Initialize configuration** (optional but recommended)
   ```bash
   toolbox config init
   ```

## 📖 Usage

### Basic Commands

| Command | Description | Example |
|---------|-------------|---------|
| `toolbox create` | Create new files/directories | `toolbox create project/` |
| `toolbox read <name>` | Read file contents | `toolbox read config.txt` |
| `toolbox delete <name>` | Delete files/directories | `toolbox delete old_file.txt` |
| `toolbox list` | List directory contents | `toolbox list ~/Downloads` |
| `toolbox help` | Show help information | `toolbox help` |

### Advanced Commands

| Command | Description | Example |
|---------|-------------|---------|
| `toolbox find <pattern>` | Find files by pattern | `toolbox find "*.log"` |
| `toolbox size <path>` | Get file/directory size | `toolbox size ~/Documents` |
| `toolbox compress <file>` | Compress files | `toolbox compress archive.tar.gz` |
| `toolbox extract <archive>` | Extract archives | `toolbox extract data.zip` |
| `toolbox ports` | Check open ports | `toolbox ports` |
| `toolbox run <script>` | Execute scripts | `toolbox run backup.sh` |

### 🔧 New System Commands

| Command | Description | Example |
|---------|-------------|---------|
| `toolbox config show` | Show current configuration | `toolbox config show` |
| `toolbox config set <key> <value>` | Set configuration value | `toolbox config set TOOLBOX_EDITOR code` |
| `toolbox logs show [lines]` | Show recent logs | `toolbox logs show 100` |
| `toolbox logs clear` | Clear all logs | `toolbox logs clear` |
| `toolbox backup create <source>` | Create backup | `toolbox backup create important_file.txt` |
| `toolbox backup list` | List all backups | `toolbox backup list` |
| `toolbox backup restore <backup>` | Restore from backup | `toolbox backup restore backup_20241201_143022` |

## ⚙️ Configuration

The toolbox uses a configuration file at `~/toolbox/config.sh`. Run `toolbox config init` to create it with defaults.

### Key Settings

```bash
# Editor preferences
export TOOLBOX_EDITOR="nano"                    # Default editor

# Backup settings
export TOOLBOX_BACKUP_DIR="$HOME/toolbox/backups"  # Backup directory
export TOOLBOX_AUTO_BACKUP="true"               # Auto-backup before destructive operations
export TOOLBOX_BACKUP_RETENTION="30"            # Days to keep backups

# Logging settings
export TOOLBOX_LOG_LEVEL="error"                # debug, info, warn, error
export TOOLBOX_LOG_FILE="$HOME/toolbox/toolbox.log"  # Log file location
export TOOLBOX_MAX_LOG_SIZE="10MB"              # Max log file size

# Safety settings
export TOOLBOX_CONFIRM_DELETE="true"            # Confirm before deleting files

# Display settings
export TOOLBOX_COLORS="true"                    # Enable colored output
export TOOLBOX_TIMESTAMP="true"                 # Show timestamps in logs

# Advanced settings
export TOOLBOX_DEBUG="false"                    # Enable debug mode
export TOOLBOX_QUIET="false"                    # Suppress non-error output
export TOOLBOX_SUPPRESS_INIT="false"            # Suppress initialization messages
```

## 🎯 Features

- ✨ **Cross-platform compatibility** - Works on Unix/Linux systems and Windows with Git Bash
- 🚀 **Fast execution** - Pure Bash implementation
- 🎨 **Beautiful output** - Colored output and icons
- 📚 **Comprehensive help** - Built-in documentation
- 🔧 **Extensible** - Easy to add new commands
- 🧪 **Tested** - Includes test suite
- 💻 **Windows support** - Full compatibility with Git Bash on Windows
- 🔧 **Configuration system** - Customize behavior to your preferences
- 📝 **Enhanced logging** - Multi-level logging with file rotation
- 🔄 **Backup system** - Automatic backups with retention policies
- 🛡️ **Safety features** - Confirmation prompts and auto-backup

## 🛠️ Development

### Adding New Tools

When adding new commands, remember to update:

1. **📝 README.md** - Add to documentation
2. **❓ help.sh** - Add help text
3. **🔧 toolbox.sh** - Add command routing
4. **📋 toolbox_aliases** - Add shell aliases

### Running Tests

```bash
# Run the test suite
./run_tests.sh

# Or use the Makefile
make test
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Made with ❤️ for developers everywhere**

[⭐ Star this repo](https://github.com/yourusername/toolbox) • [🐛 Report issues](https://github.com/yourusername/toolbox/issues) • [📖 View docs](https://github.com/yourusername/toolbox/wiki)

</div>
