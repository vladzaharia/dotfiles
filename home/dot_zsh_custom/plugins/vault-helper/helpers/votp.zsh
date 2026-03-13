# Vault OTP Utility
# Modern ZSH implementation following best practices for variable scoping and error handling
# Provides TOTP code generation and key management via Vault

#---------------------------------------------------------------
# Function:    votp
# Description: Generate TOTP codes or list available keys from Vault
# Arguments:   [-l] to list keys, [-h] for help, or <key> for TOTP code
# Returns:     0 on success, 1 on failure
# Globals:     Uses color variables
# Usage:       votp <key>      # Generate TOTP code for key
#              votp -l         # List all available keys
#              votp -h         # Show help
# Examples:    votp github     # Get TOTP code for github key
#              votp -l         # List all TOTP keys
#---------------------------------------------------------------
function votp() {
    emulate -L zsh
    setopt local_options warn_create_global

    # Ensure colors are available
    _vault_helper_Ensure_Colors

    # Validate required commands
    if ! command -v vault &> /dev/null; then
        print "${_COLOR_RED}[!]${_RESET} Error: vault must be installed to use votp!" >&2
        return 1
    fi

    # Help text if no arguments or -h is passed in
    if (( $# == 0 )) || [[ $1 == -h* ]]; then
        if (( $# == 0 )); then
            print "${_COLOR_RED}[!]${_RESET} Error: Must provide TOTP key or use -l to list keys!" >&2
            print ""
        fi

        print "${_COLOR_CYAN}[i]${_RESET} votp [-l|-h] <key>"
        print "${_COLOR_CYAN}[i]${_RESET}   <key>: TOTP key to retrieve token for"
        print "${_COLOR_CYAN}[i]${_RESET}   -l:    List all available keys"
        print "${_COLOR_CYAN}[i]${_RESET}   -h:    Show this help message"
        return (( $# == 0 ? 1 : 0 ))
    fi

    # List keys option
    if [[ $1 == -l* ]]; then
        print "${_COLOR_BLUE}[i]${_RESET} Listing available TOTP keys..."

        if vault list totp/keys 2>/dev/null; then
            return 0
        else
            print "${_COLOR_RED}[!]${_RESET} Failed to list TOTP keys. Check Vault authentication and permissions." >&2
            return 1
        fi
    else
        # Generate TOTP code for specified key
        local key="$1"

        if [[ -z "$key" ]]; then
            print "${_COLOR_RED}[!]${_RESET} Error: Key name cannot be empty!" >&2
            return 1
        fi

        print "${_COLOR_BLUE}[i]${_RESET} Generating TOTP code for key: $key"

        local totpCode
        if totpCode=$(vault read -field=code "totp/code/$key" 2>/dev/null); then
            if [[ -n "$totpCode" ]]; then
                print "$totpCode"
                return 0
            else
                print "${_COLOR_RED}[!]${_RESET} Received empty TOTP code for key: $key" >&2
                return 1
            fi
        else
            print "${_COLOR_RED}[!]${_RESET} Failed to generate TOTP code for key: $key" >&2
            print "${_COLOR_YELLOW}[!]${_RESET} Check that the key exists and you have proper permissions" >&2
            return 1
        fi
    fi
}

