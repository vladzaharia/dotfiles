# Docker-with-Vault Utility
# Modern ZSH implementation following best practices for variable scoping and error handling
# Integrates Docker with Vault for secure environment variable management

# Commands that require environment variable injection
typeset -gr ENV_INJECTED_COMMANDS=("compose up")

#---------------------------------------------------------------
# Function:    vdocker
# Description: Docker wrapper with Vault integration for secure env management
# Arguments:   Docker command arguments
# Returns:     Docker command exit code
# Globals:     Uses color variables, VAULT_SOPS_ROLE_ID, VAULT_SOPS_SECRET_ID
# Usage:       vdocker [docker-args...]
# Examples:    vdocker compose up
#              vdocker ps
#---------------------------------------------------------------
function vdocker() {
    emulate -L zsh
    setopt local_options extended_glob null_glob warn_create_global

    # Ensure colors are available
    _vault_helper_Ensure_Colors

    # Validate required commands
    if ! command -v vault &> /dev/null; then
        print "${_COLOR_RED}[!]${_RESET} Error: vault must be installed to use vdocker!" >&2
        return 1
    fi

    if ! command -v docker &> /dev/null; then
        print "${_COLOR_RED}[!]${_RESET} Error: docker must be installed to use vdocker!" >&2
        return 1
    fi

    # Help text if -h is passed in
    if [[ $1 == -h* ]]; then
        print "${_COLOR_CYAN}[i]${_RESET} vdocker [docker-args...]"
        print "${_COLOR_CYAN}[i]${_RESET}   Docker wrapper with Vault integration"
        print "${_COLOR_CYAN}[i]${_RESET}   See \`man docker\` for more information."
        return 0
    fi

    # Verify if the command we're running needs env interception
    _check_Command_Needs_Env "$@"
    local -i needsEnv=$?

    # Decrypt env files if needed
    if (( needsEnv == 1 )); then
        # Login using Vault Approle helper if needed
        if ! _vault_Approle_Login; then
            print "${_COLOR_RED}[!]${_RESET} Failed to authenticate with Vault" >&2
            return 1
        fi

        # Decrypt all env files with SOPS/Vault/age (using improved function)
        if ! _sops_decrypt "*.env"; then
            print "${_COLOR_RED}[!]${_RESET} Failed to decrypt environment files" >&2
            return 1
        fi

        # Verify decryption was successful
        local -a failedFiles=()
        local file
        for file in *.env(N); do
            if grep -qEx 'sops_version=[0-9]+\.[0-9]+\.[0-9]+' "$file" 2>/dev/null; then
                failedFiles+=("$file")
            fi
        done

        if (( ${#failedFiles[@]} > 0 )); then
            print "${_COLOR_RED}[!]${_RESET} Environment file(s) were not successfully decrypted: ${(j: :)failedFiles}" >&2
            return 1
        fi
    fi

    # Run docker subcommand
    local -i dockerExitCode
    command docker "$@"
    dockerExitCode=$?

    # Re-encrypt env files if needed
    if (( needsEnv == 1 )); then
        if ! _sops_encrypt "*.env"; then
            print "${_COLOR_YELLOW}[!]${_RESET} Warning: Failed to re-encrypt environment files" >&2
        fi
    fi

    return $dockerExitCode
}

#---------------------------------------------------------------
# Function:    _check_Command_Needs_Env
# Description: Check if the docker command requires environment variable injection
# Arguments:   Docker command arguments
# Returns:     1 if env injection needed, 0 if not
# Usage:       _check_Command_Needs_Env "$@"
#---------------------------------------------------------------
function _check_Command_Needs_Env() {
    emulate -L zsh
    setopt local_options warn_create_global

    local -a args=("$@")
    local command

    for command in "${ENV_INJECTED_COMMANDS[@]}"; do
        if [[ "${(j: :)args}" =~ $command ]]; then
            return 1
        fi
    done
    return 0
}

#---------------------------------------------------------------
# Function:    _vault_Approle_Login
# Description: Authenticate with Vault using AppRole if needed
# Arguments:   None
# Returns:     0 on success, 1 on failure
# Globals:     VAULT_SOPS_ROLE_ID, VAULT_SOPS_SECRET_ID, VAULT_TOKEN
# Usage:       _vault_Approle_Login
#---------------------------------------------------------------
function _vault_Approle_Login() {
    emulate -L zsh
    setopt local_options warn_create_global

    # Ensure colors are available
    _vault_helper_Ensure_Colors

    # Check if existing token still works
    if vault token lookup &> /dev/null; then
        return 0
    fi

    # Validate required environment variables
    if [[ -z "$VAULT_SOPS_ROLE_ID" || -z "$VAULT_SOPS_SECRET_ID" ]]; then
        print "${_COLOR_RED}[!]${_RESET} Error: VAULT_SOPS_ROLE_ID and VAULT_SOPS_SECRET_ID must be set!" >&2
        return 1
    fi

    # Attempt to authenticate
    local token
    if ! token=$(vault write -field="token" auth/approle/login role_id="$VAULT_SOPS_ROLE_ID" secret_id="$VAULT_SOPS_SECRET_ID" 2>/dev/null); then
        print "${_COLOR_RED}[!]${_RESET} Failed to authenticate with Vault using AppRole" >&2
        return 1
    fi

    if [[ -z "$token" ]]; then
        print "${_COLOR_RED}[!]${_RESET} Received empty token from Vault" >&2
        return 1
    fi

    export VAULT_TOKEN="$token"
    print "${_COLOR_GREEN}[✓]${_RESET} Successfully authenticated with Vault"
    return 0
}



# Make vdocker the default when running `docker`
alias docker=vdocker