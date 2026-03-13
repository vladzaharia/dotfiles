# Crypto Plugin
# SOPS encryption/decryption utilities with CLI interface
# Follows modern ZSH best practices for plugin organization

# Set useful ZSH options
setopt local_options warn_create_global

# Get the directory of this plugin
typeset -gr _CRYPTO_PLUGIN_DIR="${0:A:h}"

#---------------------------------------------------------------
# Load Dependencies
#---------------------------------------------------------------

# Load shared color definitions
if [[ -f "${_CRYPTO_PLUGIN_DIR}/../../lib/colors.zsh" ]]; then
    source "${_CRYPTO_PLUGIN_DIR}/../../lib/colors.zsh"
else
    # Fallback color definitions if shared colors not available
    typeset -g _COLOR_RED='\033[1;31m'
    typeset -g _COLOR_GREEN='\033[1;32m'
    typeset -g _COLOR_YELLOW='\033[1;33m'
    typeset -g _COLOR_BLUE='\033[1;34m'
    typeset -g _COLOR_CYAN='\033[1;36m'
    typeset -g _RESET='\033[0m'
    
    print "${_COLOR_YELLOW}[!]${_RESET} Warning: Shared colors not found, using fallback definitions" >&2
fi

#---------------------------------------------------------------
# Load Plugin Components
#---------------------------------------------------------------

# Load utility functions
if [[ -f "${_CRYPTO_PLUGIN_DIR}/utils.zsh" ]]; then
    source "${_CRYPTO_PLUGIN_DIR}/utils.zsh"
else
    print "${_COLOR_RED:-}[!]${_RESET:-} Error: Crypto utilities not found at ${_CRYPTO_PLUGIN_DIR}/utils.zsh" >&2
    return 1
fi

# Load CLI interface
if [[ -f "${_CRYPTO_PLUGIN_DIR}/cli.zsh" ]]; then
    source "${_CRYPTO_PLUGIN_DIR}/cli.zsh"
else
    print "${_COLOR_RED:-}[!]${_RESET:-} Error: Crypto CLI not found at ${_CRYPTO_PLUGIN_DIR}/cli.zsh" >&2
    return 1
fi

#---------------------------------------------------------------
# Plugin Information
#---------------------------------------------------------------

# Plugin metadata
typeset -gr _CRYPTO_PLUGIN_VERSION="1.0.0"
typeset -gr _CRYPTO_PLUGIN_AUTHOR="Vlad Zaharia"
typeset -gr _CRYPTO_PLUGIN_DESCRIPTION="SOPS encryption/decryption utilities with CLI interface"

#---------------------------------------------------------------
# Function:    crypto_Plugin_Info
# Description: Display information about the crypto plugin
# Arguments:   None
# Returns:     0 (always successful)
# Usage:       crypto_Plugin_Info
#---------------------------------------------------------------
function crypto_Plugin_Info() {
    emulate -L zsh
    setopt local_options warn_create_global
    
    print "${_COLOR_CYAN:-}Crypto Plugin Information${_RESET:-}"
    print ""
    print "${_COLOR_BLUE:-}Version:${_RESET:-}     $_CRYPTO_PLUGIN_VERSION"
    print "${_COLOR_BLUE:-}Author:${_RESET:-}      $_CRYPTO_PLUGIN_AUTHOR"
    print "${_COLOR_BLUE:-}Description:${_RESET:-} $_CRYPTO_PLUGIN_DESCRIPTION"
    print ""
    print "${_COLOR_BLUE:-}Available Commands:${_RESET:-}"
    print "  ${_COLOR_GREEN:-}crypto${_RESET:-}        Main CLI interface for SOPS utilities"
    print "  ${_COLOR_GREEN:-}_sops_encrypt${_RESET:-}    Encrypt files using SOPS (internal)"
    print "  ${_COLOR_GREEN:-}_sops_decrypt${_RESET:-}    Decrypt files using SOPS (internal)"
    print ""
    print "${_COLOR_BLUE:-}Usage:${_RESET:-}"
    print "  ${_COLOR_YELLOW:-}crypto help${_RESET:-}   Show detailed help information"
    print "  ${_COLOR_YELLOW:-}colors_Test${_RESET:-}      Test color support (if colors loaded)"
    
    return 0
}

#---------------------------------------------------------------
# Validation
#---------------------------------------------------------------

# Validate that SOPS is available (optional check)
if ! command -v sops &> /dev/null; then
    print "${_COLOR_YELLOW:-}[!]${_RESET:-} Warning: SOPS not found. Install SOPS to use encryption/decryption features." >&2
fi

# Success message (only in verbose mode)
if [[ -n "$ZSH_PLUGIN_VERBOSE" ]]; then
    print "${_COLOR_GREEN:-}[✓]${_RESET:-} Crypto plugin loaded successfully"
fi
