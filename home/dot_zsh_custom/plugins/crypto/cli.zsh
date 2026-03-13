# SOPS Utility CLI
# Provides user-friendly command-line interface for SOPS encryption/decryption utilities
# Follows modern ZSH best practices for variable scoping, error handling, and function naming

#---------------------------------------------------------------
# Function:    crypto
# Description: Main CLI interface for SOPS encryption/decryption utilities
# Arguments:   command [file-patterns...]
# Returns:     0 on success, 1 on failure
# Globals:     Uses color variables if available
# Usage:       crypto <command> [patterns...]
# Examples:    crypto encrypt
#              crypto decrypt "*.yaml"
#              crypto help
#---------------------------------------------------------------
function crypto() {
    emulate -L zsh
    setopt local_options warn_create_global

    # Ensure colors are available (fallback if not loaded by plugin)
    if [[ -z "$_COLOR_RED" ]]; then
        typeset -g _COLOR_RED='\033[1;31m'
        typeset -g _COLOR_GREEN='\033[1;32m'
        typeset -g _COLOR_YELLOW='\033[1;33m'
        typeset -g _COLOR_BLUE='\033[1;34m'
        typeset -g _COLOR_CYAN='\033[1;36m'
        typeset -g _RESET='\033[0m'
    fi

    local command="$1"
    shift

    # Validate that command is provided
    if [[ -z "$command" ]]; then
        command="help"
    fi

    case "$command" in
        "encrypt"|"enc"|"e")
            _sops_encrypt "$@"
            ;;
        "decrypt"|"dec"|"d")
            _sops_decrypt "$@"
            ;;
        "help"|"h"|"-h"|"--help")
            _sops_util_Help
            ;;
        *)
            print "${_COLOR_RED}[!]${_RESET} Unknown command: $command" >&2
            print ""
            _sops_util_Help
            return 1
            ;;
    esac
}

#---------------------------------------------------------------
# Function:    _sops_util_Help
# Description: Display help information for the SOPS utility CLI
# Arguments:   None
# Returns:     0 (always successful)
# Globals:     Uses color variables if available
# Usage:       _sops_util_Help
#---------------------------------------------------------------
function _sops_util_Help() {
    emulate -L zsh
    setopt local_options warn_create_global

    # Ensure colors are available (fallback if not loaded by plugin)
    if [[ -z "$_COLOR_RED" ]]; then
        typeset -g _COLOR_RED='\033[1;31m'
        typeset -g _COLOR_GREEN='\033[1;32m'
        typeset -g _COLOR_YELLOW='\033[1;33m'
        typeset -g _COLOR_BLUE='\033[1;34m'
        typeset -g _COLOR_CYAN='\033[1;36m'
        typeset -g _RESET='\033[0m'
    fi

    print "${_COLOR_CYAN}SOPS Utility CLI${_RESET}"
    print ""
    print "${_COLOR_BLUE}Usage:${_RESET}"
    print "  crypto <command> [file-patterns...]"
    print ""
    print "${_COLOR_BLUE}Commands:${_RESET}"
    print "  ${_COLOR_GREEN}encrypt, enc, e${_RESET}    Encrypt files using SOPS"
    print "  ${_COLOR_GREEN}decrypt, dec, d${_RESET}    Decrypt files using SOPS"
    print "  ${_COLOR_GREEN}help, h${_RESET}            Show this help message"
    print ""
    print "${_COLOR_BLUE}Examples:${_RESET}"
    print "  ${_COLOR_YELLOW}crypto encrypt${_RESET}                    # Encrypt all *.env files (default)"
    print "  ${_COLOR_YELLOW}crypto decrypt config.yaml${_RESET}       # Decrypt specific file"
    print "  ${_COLOR_YELLOW}crypto enc \"*.json\" \"*.yaml\"${_RESET}     # Encrypt multiple patterns"
    print "  ${_COLOR_YELLOW}crypto dec secrets/*.env${_RESET}         # Decrypt files in subdirectory"
    print "  ${_COLOR_YELLOW}crypto e file1.env file2.yaml${_RESET}    # Encrypt specific files"
    print ""
    print "${_COLOR_BLUE}Notes:${_RESET}"
    print "  • If no file patterns are specified, defaults to *.env"
    print "  • Supports glob patterns and specific file paths"
    print "  • Only processes files that need encryption/decryption"
    print "  • Files are encrypted/decrypted in-place (-i flag)"
    print "  • Requires SOPS to be installed and configured"

    return 0
}
