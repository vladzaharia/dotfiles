# Vault Login Utility
# Modern ZSH implementation following best practices for variable scoping and error handling
# Provides OIDC authentication with Vault

#---------------------------------------------------------------
# Function:    vlogin
# Description: Login to Vault using OIDC authentication
# Arguments:   [-t] for token output, [-h] for help
# Returns:     0 on success, 1 on failure
# Globals:     Uses color variables
# Usage:       vlogin [-t|-h]
# Examples:    vlogin          # Login without printing token
#              vlogin -t       # Login and print token
#---------------------------------------------------------------
function vlogin() {
    emulate -L zsh
    setopt local_options warn_create_global

    # Ensure colors are available
    _vault_helper_Ensure_Colors

    # Validate required commands
    if ! command -v vault &> /dev/null; then
        print "${_COLOR_RED}[!]${_RESET} Error: vault must be installed to use vlogin!" >&2
        return 1
    fi

    # Help text if -h is passed in
    if [[ $1 == -h* ]]; then
        print "${_COLOR_CYAN}[i]${_RESET} vlogin [-t|-h]"
        print "${_COLOR_CYAN}[i]${_RESET}   -t: Print out token after login"
        print "${_COLOR_CYAN}[i]${_RESET}   -h: Show this help message"
        print "${_COLOR_CYAN}[i]${_RESET}   Uses OIDC authentication method"
        return 0
    fi

    local -a vaultArgs=("-no-print")

    # Print out token when -t is passed in
    if [[ $1 == -t* ]]; then
        vaultArgs=("-field=token")
    fi

    # Perform Vault OIDC login using Authentik
    print "${_COLOR_BLUE}[i]${_RESET} Authenticating with Vault using OIDC..."
    if vault login -method=oidc "${vaultArgs[@]}"; then
        print "${_COLOR_GREEN}[✓]${_RESET} Successfully authenticated with Vault"
        return 0
    else
        print "${_COLOR_RED}[!]${_RESET} Failed to authenticate with Vault" >&2
        return 1
    fi
}


