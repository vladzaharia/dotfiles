# Vault Environment Variable Utility
# Modern ZSH implementation following best practices for variable scoping and error handling
# Provides environment variable injection and cleanup for projects

#---------------------------------------------------------------
# Function:    vnv
# Description: Inject or cleanup environment variables for a project from Vault
# Arguments:   [-c] for cleanup, [-h] for help, [project] name
# Returns:     0 on success, 1 on failure
# Globals:     Uses color variables, PWD
# Usage:       vnv [project]       # Inject variables for project
#              vnv -c [project]    # Cleanup variables for project
# Examples:    vnv myapp           # Inject variables for myapp
#              vnv -c myapp        # Cleanup variables for myapp
#              vnv                 # Use current directory name
#---------------------------------------------------------------
function vnv() {
    emulate -L zsh
    setopt local_options warn_create_global

    # Ensure colors are available
    _vault_helper_Ensure_Colors

    # Validate required commands
    if ! command -v vault &> /dev/null; then
        print "${_COLOR_RED}[!]${_RESET} Error: vault must be installed to use vnv!" >&2
        return 1
    fi

    if ! command -v jq &> /dev/null; then
        print "${_COLOR_RED}[!]${_RESET} Error: jq must be installed to use vnv!" >&2
        return 1
    fi

    # Help text if -h is passed in
    if [[ $1 == -h* ]]; then
        print "${_COLOR_CYAN}[i]${_RESET} vnv [-c|-h] [project]"
        print "${_COLOR_CYAN}[i]${_RESET}   project: Project to get dotenv variables for"
        print "${_COLOR_CYAN}[i]${_RESET}   -c:      Cleanup environment variables for project"
        print "${_COLOR_CYAN}[i]${_RESET}   -h:      Show this help message"
        print ""
        print "${_COLOR_CYAN}[i]${_RESET} Examples:"
        print "${_COLOR_CYAN}[i]${_RESET}   vnv myapp    # Inject variables for myapp project"
        print "${_COLOR_CYAN}[i]${_RESET}   vnv -c myapp # Cleanup variables for myapp project"
        print "${_COLOR_CYAN}[i]${_RESET}   vnv          # Use current directory name as project"
        return 0
    fi

    # Determine if cleanup mode
    local -i cleanupMode=0
    local vaultProject="$1"

    if [[ $1 == -c* ]]; then
        cleanupMode=1
        vaultProject="$2"
    fi

    # Determine project to use, defaults to current working directory
    if [[ -z "$vaultProject" ]]; then
        vaultProject="${PWD##*/}"
        print "${_COLOR_YELLOW}[!]${_RESET} No project specified, using current directory: '$vaultProject'"
    fi

    # Validate project name
    if [[ -z "$vaultProject" ]]; then
        print "${_COLOR_RED}[!]${_RESET} Error: Project name cannot be empty!" >&2
        return 1
    fi

    local vaultPath="dotenv/$vaultProject/dev"

    if (( cleanupMode == 1 )); then
        print "${_COLOR_YELLOW}[!]${_RESET} Cleaning environment variables for project: '$vaultProject'"
    else
        print "${_COLOR_BLUE}[i]${_RESET} Injecting variables from: $vaultPath"
    fi

    # Get JSON from Vault and parse environment variables
    local json
    if ! json=$(vault read -format=raw "$vaultPath" 2>/dev/null); then
        print "${_COLOR_RED}[!]${_RESET} Error: Failed to read from Vault path: $vaultPath" >&2
        print "${_COLOR_YELLOW}[!]${_RESET} Check that the path exists and you have proper permissions" >&2
        return 1
    fi

    if [[ -z "$json" ]]; then
        print "${_COLOR_RED}[!]${_RESET} Error: Received empty response from Vault" >&2
        return 1
    fi

    # Parse JSON and extract environment variables
    local -a envVars
    if ! envVars=($(echo "$json" | jq -r '.data | to_entries | map(.key+"="+.value) | @sh' 2>/dev/null)); then
        print "${_COLOR_RED}[!]${_RESET} Error: Failed to parse JSON response from Vault" >&2
        return 1
    fi

    if (( ${#envVars[@]} == 0 )); then
        print "${_COLOR_YELLOW}[!]${_RESET} No environment variables found for project: $vaultProject"
        return 0
    fi

    local -i successCount=0
    local -i errorCount=0
    local envVar exportStr key

    for envVar in "${envVars[@]}"; do
        # Remove surrounding quotes from jq output
        exportStr="${envVar//\'/}"

        # Extract key name (everything before first =)
        key="${exportStr%%=*}"

        if [[ -z "$key" ]]; then
            print "${_COLOR_RED}[!]${_RESET} Warning: Skipping invalid environment variable: $exportStr" >&2
            ((errorCount++))
            continue
        fi

        if (( cleanupMode == 1 )); then
            # Clean up by unsetting key
            unset "$key"
            print "${_COLOR_GREEN}[✓]${_RESET} Cleaned up: $key"
            ((successCount++))
        else
            # Export environment variable
            if export "$exportStr" 2>/dev/null; then
                print "${_COLOR_GREEN}[✓]${_RESET} Injected: $key"
                ((successCount++))
            else
                print "${_COLOR_RED}[!]${_RESET} Failed to export: $key" >&2
                ((errorCount++))
            fi
        fi
    done

    # Summary
    if (( cleanupMode == 1 )); then
        print "${_COLOR_BLUE}[i]${_RESET} Cleanup complete: $successCount variables cleaned, $errorCount errors"
    else
        print "${_COLOR_BLUE}[i]${_RESET} Injection complete: $successCount variables injected, $errorCount errors"
    fi

    return (( errorCount == 0 ? 0 : 1 ))
}

