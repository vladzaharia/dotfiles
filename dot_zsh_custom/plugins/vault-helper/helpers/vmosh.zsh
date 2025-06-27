# Vault Mosh Utility
# Modern ZSH implementation following best practices for variable scoping and error handling
# Provides Mosh connections using Vault-signed certificates

#---------------------------------------------------------------
# Function:    vmosh
# Description: Connect to remote machine using Mosh with Vault SSH certificate
# Arguments:   [-r] for root, [-h] for help, [username@]hostname
# Returns:     Mosh connection exit code
# Globals:     Uses color variables, USER
# Usage:       vmosh [username@]hostname
#              vmosh -r hostname        # Connect as root
# Examples:    vmosh server.example.com
#              vmosh user@server.example.com
#              vmosh -r server.example.com
#---------------------------------------------------------------
function vmosh() {
    emulate -L zsh
    setopt local_options warn_create_global

    # Ensure colors are available
    _vault_helper_Ensure_Colors

    # Validate required commands
    if ! command -v vault &> /dev/null; then
        print "${_COLOR_RED}[!]${_RESET} Error: vault must be installed to use vmosh!" >&2
        return 1
    fi

    local moshBin
    if ! moshBin=$(command -v mosh); then
        print "${_COLOR_RED}[!]${_RESET} Error: mosh must be installed to use vmosh!" >&2
        return 1
    fi

    # Help text if no hostname is entered or -h is passed in
    if (( $# == 0 )) || [[ $1 == -h* ]]; then
        if (( $# == 0 )); then
            print "${_COLOR_RED}[!]${_RESET} Error: Must provide hostname!" >&2
            print ""
        fi

        print "${_COLOR_CYAN}[i]${_RESET} vmosh [-r|-h] [username@]<hostname>"
        print "${_COLOR_CYAN}[i]${_RESET}   hostname: Computer to connect to"
        print "${_COLOR_CYAN}[i]${_RESET}   username: User to connect as (defaults to current user)"
        print "${_COLOR_CYAN}[i]${_RESET}   -r:       Connect as root user"
        print "${_COLOR_CYAN}[i]${_RESET}   -h:       Show this help message"
        return (( $# == 0 ? 1 : 0 ))
    fi

    # Set default values
    local vaultMode="ca"
    local vaultRole="user"
    local username="$USER"
    local hostname="$1"

    # Find SSH key
    local sshKey
    if ! _vault_helper_Find_SSH_Key sshKey; then
        print "${_COLOR_RED}[!]${_RESET} Error: No SSH key found in ~/.ssh/" >&2
        return 1
    fi

    print "${_COLOR_BLUE}[i]${_RESET} Using SSH key: $HOME/.ssh/$sshKey.pub"

    # Determine if we should be connecting as root
    if [[ $1 == -r* ]] || [[ $3 == -r* ]]; then
        print "${_COLOR_YELLOW}[!]${_RESET} Connecting as root user"
        vaultRole="root"
        username="root"
        hostname="$2"
    fi

    # Validate hostname
    if [[ -z "$hostname" ]]; then
        print "${_COLOR_RED}[!]${_RESET} Error: No hostname provided!" >&2
        return 1
    fi

    # Build connection string
    local connString="$username@$hostname"
    # Check if full connection string was passed in
    if [[ $hostname == *@* ]]; then
        connString="$hostname"
    fi

    # Validate SSH key files exist
    if [[ ! -f "$HOME/.ssh/$sshKey.pub" ]]; then
        print "${_COLOR_RED}[!]${_RESET} Error: Public key not found: $HOME/.ssh/$sshKey.pub" >&2
        return 1
    fi

    if [[ ! -f "$HOME/.ssh/$sshKey" ]]; then
        print "${_COLOR_RED}[!]${_RESET} Error: Private key not found: $HOME/.ssh/$sshKey" >&2
        return 1
    fi

    # Execute vault SSH with Mosh
    print "${_COLOR_BLUE}[i]${_RESET} Connecting to $connString using Vault SSH with Mosh..."
    vault ssh -mode="$vaultMode" -role="$vaultRole" \
        -public-key-path="$HOME/.ssh/$sshKey.pub" \
        -private-key-path="$HOME/.ssh/$sshKey" \
        -ssh-executable="$moshBin" \
        "$connString"
}

