# Vault Token Utility
# Modern ZSH implementation following best practices for variable scoping and error handling
# Provides token information lookup and capability checking

#---------------------------------------------------------------
# Function:    vtoken
# Description: Lookup token information and check capabilities
# Arguments:   [token] [path] - optional token and path for capability check
# Returns:     0 on success, 1 on failure
# Globals:     Uses color variables
# Usage:       vtoken              # Lookup current token
#              vtoken <token>      # Lookup specific token
#              vtoken <token> <path> # Check token capabilities for path
# Examples:    vtoken
#              vtoken hvs.XXXXXX
#              vtoken hvs.XXXXXX secret/data/myapp
#---------------------------------------------------------------
function vtoken() {
    emulate -L zsh
    setopt local_options warn_create_global

    # Ensure colors are available
    _vault_helper_Ensure_Colors

    # Validate required commands
    if ! command -v vault &> /dev/null; then
        print "${_COLOR_RED}[!]${_RESET} Error: vault must be installed to use vtoken!" >&2
        return 1
    fi

    # Help text if -h is passed in
    if [[ $1 == -h* ]]; then
        print "${_COLOR_CYAN}[i]${_RESET} vtoken [-h] [token] [path]"
        print "${_COLOR_CYAN}[i]${_RESET}   token: Token to get information for (optional)"
        print "${_COLOR_CYAN}[i]${_RESET}   path:  Check capabilities of token against path"
        print "${_COLOR_CYAN}[i]${_RESET}   -h:    Show this help message"
        print ""
        print "${_COLOR_CYAN}[i]${_RESET} Examples:"
        print "${_COLOR_CYAN}[i]${_RESET}   vtoken                    # Lookup current token"
        print "${_COLOR_CYAN}[i]${_RESET}   vtoken hvs.XXXXXX         # Lookup specific token"
        print "${_COLOR_CYAN}[i]${_RESET}   vtoken hvs.XXXXXX secret/ # Check token capabilities"
        return 0
    fi

    case $# in
        0)
            # Current token lookup
            print "${_COLOR_BLUE}[i]${_RESET} Looking up current token information..."
            if vault token lookup; then
                return 0
            else
                print "${_COLOR_RED}[!]${_RESET} Failed to lookup current token" >&2
                return 1
            fi
            ;;
        1)
            # Specific token lookup
            local token="$1"
            if [[ -z "$token" ]]; then
                print "${_COLOR_RED}[!]${_RESET} Error: Token cannot be empty!" >&2
                return 1
            fi

            print "${_COLOR_BLUE}[i]${_RESET} Looking up token information for: ${token:0:10}..."
            if vault token lookup "$token"; then
                return 0
            else
                print "${_COLOR_RED}[!]${_RESET} Failed to lookup token information" >&2
                return 1
            fi
            ;;
        2)
            # Token capability check against path
            local token="$1"
            local path="$2"

            if [[ -z "$token" ]]; then
                print "${_COLOR_RED}[!]${_RESET} Error: Token cannot be empty!" >&2
                return 1
            fi

            if [[ -z "$path" ]]; then
                print "${_COLOR_RED}[!]${_RESET} Error: Path cannot be empty!" >&2
                return 1
            fi

            print "${_COLOR_BLUE}[i]${_RESET} Checking token capabilities for path: $path"
            if vault token capabilities "$token" "$path"; then
                return 0
            else
                print "${_COLOR_RED}[!]${_RESET} Failed to check token capabilities" >&2
                return 1
            fi
            ;;
        *)
            print "${_COLOR_RED}[!]${_RESET} Error: Too many arguments provided!" >&2
            print "${_COLOR_YELLOW}[!]${_RESET} Use 'vtoken -h' for help" >&2
            return 1
            ;;
    esac
}


