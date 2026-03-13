# Crypto Plugin

SOPS encryption/decryption utilities with CLI interface following modern ZSH best practices.

## Features

- **Modern ZSH Implementation**: Follows current best practices for variable scoping, error handling, and function naming
- **Flexible File Patterns**: Supports glob patterns and individual files
- **Robust Error Handling**: Comprehensive validation and error reporting
- **CLI Interface**: User-friendly command-line interface with help system
- **Color Support**: Consistent colored output with fallback support

## Installation

The plugin is automatically loaded if placed in your ZSH custom plugins directory:

```
~/.zsh_custom/plugins/crypto/
├── crypto.plugin.zsh    # Main plugin file
├── utils.zsh           # Core utility functions
├── cli.zsh            # CLI interface
└── README.md          # This file
```

## Usage

### CLI Interface

```bash
# Encrypt files (defaults to *.env)
crypto encrypt

# Decrypt files
crypto decrypt

# Work with specific files
crypto encrypt config.yaml
crypto decrypt secrets.json

# Use glob patterns
crypto enc "*.json" "*.yaml"
crypto dec "config/*.env"

# Get help
crypto help
```

### Direct Function Usage

```bash
# Use utility functions directly
_sops_encrypt "*.env"
_sops_decrypt "config/*.yaml"
```

## Commands

- `encrypt`, `enc`, `e` - Encrypt files using SOPS
- `decrypt`, `dec`, `d` - Decrypt files using SOPS  
- `help`, `h` - Show help information

## Requirements

- **SOPS**: Must be installed and configured
- **ZSH**: Modern ZSH shell
- **Colors**: Uses shared color library (with fallbacks)

## File Structure

- **`crypto.plugin.zsh`**: Main plugin loader with dependency management
- **`utils.zsh`**: Core SOPS encryption/decryption functions
- **`cli.zsh`**: User-friendly CLI interface

## Dependencies

- Shared color library (`../../lib/colors.zsh`) - optional with fallbacks
- SOPS command-line tool - required for functionality

## Examples

```bash
# Basic usage
crypto encrypt                    # Encrypt all *.env files
crypto decrypt                    # Decrypt all *.env files

# Specific files
crypto encrypt config.yaml       # Encrypt one file
crypto decrypt secrets.json      # Decrypt one file

# Multiple patterns
crypto enc "*.json" "*.yaml"     # Encrypt JSON and YAML files
crypto dec "secrets/*.env"       # Decrypt env files in secrets/

# Mixed usage
crypto e file1.env file2.yaml "config/*.json"
```

## Plugin Information

Use `crypto_Plugin_Info` to display plugin metadata and available commands.

## Color Testing

If colors are loaded, use `colors_Test` to verify color support in your terminal.
