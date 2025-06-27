# Vault Helper Utilities
# Shared utility functions for the vault-helper plugin
# Modern ZSH implementation following best practices

#---------------------------------------------------------------
# Function:    _vault_helper_Ensure_Colors
# Description: Ensure color variables are available with fallbacks
# Arguments:   None
# Returns:     0 (always successful)
# Usage:       _vault_helper_Ensure_Colors
#---------------------------------------------------------------
function _vault_helper_Ensure_Colors() {
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
# Function:    _vault_helper_Find_SSH_Key
# Description: Find available SSH key in ~/.ssh directory
# Arguments:   Variable name to store the found key
# Returns:     0 if key found, 1 if no key found
# Usage:       _vault_helper_Find_SSH_Key varname
#---------------------------------------------------------------
function _vault_helper_Find_SSH_Key() {
    emulate -L zsh
    setopt local_options warn_create_global
    
    local -n keyVar=$1
    
    # All possible key file names (ordered by preference)
    local -a possibleKeys=(id_ed25519 id_ecdsa id_rsa id_dsa id_pkmn)
    local possibleKey

    for possibleKey in "${possibleKeys[@]}"; do
        # Check if both public and private key exist
        if [[ -f "$HOME/.ssh/$possibleKey.pub" && -f "$HOME/.ssh/$possibleKey" ]]; then
            keyVar="$possibleKey"
            return 0
        fi
    done
    
    return 1
}

#---------------------------------------------------------------
# Function:    _vault_helper_Validate_Commands
# Description: Validate that required commands are available
# Arguments:   List of command names to validate
# Returns:     0 if all commands available, 1 if any missing
# Usage:       _vault_helper_Validate_Commands vault ssh jq
#---------------------------------------------------------------
function _vault_helper_Validate_Commands() {
    emulate -L zsh
    setopt local_options warn_create_global
    
    local command
    local -a missingCommands=()
    
    for command in "$@"; do
        if ! command -v "$command" &> /dev/null; then
            missingCommands+=("$command")
        fi
    done
    
    if (( ${#missingCommands[@]} > 0 )); then
        _vault_helper_Ensure_Colors
        print "${_COLOR_RED}[!]${_RESET} Error: Missing required commands: ${(j:, :)missingCommands}" >&2
        return 1
    fi
    
    return 0
}
