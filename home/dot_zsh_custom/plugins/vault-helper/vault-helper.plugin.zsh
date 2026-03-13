# Vault Helper Plugin
# Vault utilities and helpers with Docker integration
# Follows modern ZSH best practices for plugin organization

# Set useful ZSH options
setopt local_options warn_create_global

# Get the directory of this plugin
typeset -gr _VAULT_HELPER_PLUGIN_DIR="${0:A:h}"

#---------------------------------------------------------------
# Load Dependencies
#---------------------------------------------------------------

# Load shared color definitions
if [[ -f "${_VAULT_HELPER_PLUGIN_DIR}/../../lib/colors.zsh" ]]; then
    source "${_VAULT_HELPER_PLUGIN_DIR}/../../lib/colors.zsh"
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

# Load shared utilities first
source ${0:A:h}/helpers/utils.zsh

# Load individual helper modules
source ${0:A:h}/helpers/vlogin.zsh
source ${0:A:h}/helpers/vdocker.zsh
source ${0:A:h}/helpers/votp.zsh
source ${0:A:h}/helpers/vssh.zsh
source ${0:A:h}/helpers/vmosh.zsh
source ${0:A:h}/helpers/vtoken.zsh
source ${0:A:h}/helpers/vnv.zsh

# Success message (only in verbose mode)
if [[ -n "$ZSH_PLUGIN_VERBOSE" ]]; then
    print "${_COLOR_GREEN:-}[✓]${_RESET:-} Vault Helper plugin loaded successfully"
fi
