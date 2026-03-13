# SOPS Crypto Utilities
#
# Modern ZSH implementation of SOPS encryption/decryption utilities
# Follows ZSH best practices for variable scoping, error handling, and function naming
# Supports glob patterns and individual files with robust error handling
#
# Note: This file expects color variables to be loaded by the plugin system
# Colors are loaded via crypto.plugin.zsh which sources lib/colors.zsh

#---------------------------------------------------------------
# Color Validation Function
# Ensures color variables are available with safe fallbacks
#---------------------------------------------------------------
function _crypto_Ensure_Colors() {
    # Only define fallbacks if colors aren't already defined
    if [[ -z "$_COLOR_RED" ]]; then
        typeset -g _COLOR_RED='\033[1;31m'
        typeset -g _COLOR_GREEN='\033[1;32m'
        typeset -g _COLOR_YELLOW='\033[1;33m'
        typeset -g _COLOR_BLUE='\033[1;34m'
        typeset -g _COLOR_CYAN='\033[1;36m'
        typeset -g _RESET='\033[0m'
    fi
}

#---------------------------------------------------------------
# Function:    _sops_decrypt
# Description: Decrypt SOPS-encrypted files with support for glob patterns
# Arguments:   File patterns (defaults to *.env if none provided)
# Returns:     0 on success, 1 on failure
# Globals:     Uses color variables if available
# Usage:       _sops_decrypt [pattern1] [pattern2] ...
# Examples:    _sops_decrypt
#              _sops_decrypt "*.yaml" "config/*.json"
#---------------------------------------------------------------
function _sops_decrypt() {
    emulate -L zsh
    setopt local_options extended_glob null_glob warn_create_global

    # Ensure colors are available
    _crypto_Ensure_Colors

    # Validate SOPS is available
    if ! command -v sops &> /dev/null; then
        print "${_COLOR_RED}[!]${_RESET} Error: SOPS command not found. Please install SOPS." >&2
        return 1
    fi

    local -a patterns files expanded
    local pattern file

    patterns=("$@")

    # Default to *.env if no arguments provided
    if (( ${#patterns} == 0 )); then
        patterns=("*.env")
    fi

    print "${_COLOR_BLUE}[i]${_RESET} Running decryption on files matching: ${(j: :)patterns}"

    # Expand all patterns and collect matching files
    for pattern in "${patterns[@]}"; do
        # Use parameter expansion with glob qualifiers for file existence
        expanded=(${~pattern}(N))
        for file in "${expanded[@]}"; do
            [[ -f "$file" ]] && files+=("$file")
        done
    done

    if (( ${#files} == 0 )); then
        print "${_COLOR_YELLOW}[!]${_RESET} No files found matching the specified patterns!" >&2
        return 1
    fi

    local -i exit_code=0
    for file in "${files[@]}"; do
        if grep -qEx 'sops_version=[0-9]+\.[0-9]+\.[0-9]+' "$file" 2>/dev/null; then
            print "${_COLOR_GREEN}[✓]${_RESET} Decrypting ${file}"
            if ! sops decrypt -i "$file"; then
                print "${_COLOR_RED}[!]${_RESET} Failed to decrypt ${file}" >&2
                exit_code=1
            fi
        else
            print "${_COLOR_YELLOW}[!]${_RESET} ${file} does not need decryption!"
        fi
    done

    return $exit_code
}

#---------------------------------------------------------------
# Function:    _sops_encrypt
# Description: Encrypt files with SOPS with support for glob patterns
# Arguments:   File patterns (defaults to *.env if none provided)
# Returns:     0 on success, 1 on failure
# Globals:     Uses color variables if available
# Usage:       _sops_encrypt [pattern1] [pattern2] ...
# Examples:    _sops_encrypt
#              _sops_encrypt "*.yaml" "config/*.json"
#---------------------------------------------------------------
function _sops_encrypt() {
    emulate -L zsh
    setopt local_options extended_glob null_glob warn_create_global

    # Ensure colors are available
    _crypto_Ensure_Colors

    # Validate SOPS is available
    if ! command -v sops &> /dev/null; then
        print "${_COLOR_RED}[!]${_RESET} Error: SOPS command not found. Please install SOPS." >&2
        return 1
    fi

    local -a patterns files expanded
    local pattern file

    patterns=("$@")

    # Default to *.env if no arguments provided
    if (( ${#patterns} == 0 )); then
        patterns=("*.env")
    fi

    print "${_COLOR_BLUE}[i]${_RESET} Running encryption on files matching: ${(j: :)patterns}"

    # Expand all patterns and collect matching files
    for pattern in "${patterns[@]}"; do
        # Use parameter expansion with glob qualifiers for file existence
        expanded=(${~pattern}(N))
        for file in "${expanded[@]}"; do
            [[ -f "$file" ]] && files+=("$file")
        done
    done

    if (( ${#files} == 0 )); then
        print "${_COLOR_YELLOW}[!]${_RESET} No files found matching the specified patterns!" >&2
        return 1
    fi

    local -i exit_code=0
    for file in "${files[@]}"; do
        if ! grep -qEx 'sops_version=[0-9]+\.[0-9]+\.[0-9]+' "$file" 2>/dev/null; then
            print "${_COLOR_GREEN}[✓]${_RESET} Encrypting ${file}"
            if ! sops encrypt -i "$file"; then
                print "${_COLOR_RED}[!]${_RESET} Failed to encrypt ${file}" >&2
                exit_code=1
            fi
        else
            print "${_COLOR_YELLOW}[!]${_RESET} ${file} does not need encryption!"
        fi
    done

    return $exit_code
}