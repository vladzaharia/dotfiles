# ZSH Color Definitions
# Shared color constants for consistent terminal output across plugins
# Follows modern ZSH best practices for variable scoping and naming

# Prevent multiple loading of color definitions
if [[ -n "$_ZSH_COLORS_LOADED" ]]; then
    return 0
fi

# Set useful ZSH options for better variable management
setopt local_options warn_create_global

#---------------------------------------------------------------
# Color Constants
# Uses ANSI escape sequences for terminal colors
# Global read-only variables following ZSH naming conventions
#---------------------------------------------------------------

# Basic Colors
typeset -gr _COLOR_RED='\033[1;31m'
typeset -gr _COLOR_GREEN='\033[1;32m'
typeset -gr _COLOR_YELLOW='\033[1;33m'
typeset -gr _COLOR_BLUE='\033[1;34m'
typeset -gr _COLOR_MAGENTA='\033[1;35m'
typeset -gr _COLOR_CYAN='\033[1;36m'
typeset -gr _COLOR_WHITE='\033[1;37m'
typeset -gr _COLOR_BLACK='\033[1;30m'

# Extended Colors
typeset -gr _COLOR_ORANGE='\033[1;38;5;208m'
typeset -gr _COLOR_PURPLE='\033[1;38;5;129m'
typeset -gr _COLOR_PINK='\033[1;38;5;205m'
typeset -gr _COLOR_LIME='\033[1;38;5;154m'

# Background Colors
typeset -gr _BG_RED='\033[41m'
typeset -gr _BG_GREEN='\033[42m'
typeset -gr _BG_YELLOW='\033[43m'
typeset -gr _BG_BLUE='\033[44m'
typeset -gr _BG_MAGENTA='\033[45m'
typeset -gr _BG_CYAN='\033[46m'
typeset -gr _BG_WHITE='\033[47m'
typeset -gr _BG_BLACK='\033[40m'

# Text Formatting
typeset -gr _BOLD='\033[1m'
typeset -gr _DIM='\033[2m'
typeset -gr _ITALIC='\033[3m'
typeset -gr _UNDERLINE='\033[4m'
typeset -gr _BLINK='\033[5m'
typeset -gr _REVERSE='\033[7m'
typeset -gr _STRIKETHROUGH='\033[9m'

# Reset
typeset -gr _RESET='\033[0m'

# Semantic Color Aliases for Common Use Cases
typeset -gr _COLOR_SUCCESS="$_COLOR_GREEN"
typeset -gr _COLOR_WARNING="$_COLOR_YELLOW"
typeset -gr _COLOR_ERROR="$_COLOR_RED"
typeset -gr _COLOR_INFO="$_COLOR_BLUE"
typeset -gr _COLOR_DEBUG="$_COLOR_CYAN"
typeset -gr _COLOR_HIGHLIGHT="$_COLOR_MAGENTA"

#---------------------------------------------------------------
# Function:    colors_Available
# Description: Check if terminal supports colors
# Arguments:   None
# Returns:     0 if colors supported, 1 if not
# Usage:       colors_Available && echo "Colors supported"
#---------------------------------------------------------------
function colors_Available() {
    [[ -t 1 && -n "$TERM" && "$TERM" != "dumb" ]]
}

# Mark colors as loaded to prevent duplicate loading
typeset -gr _ZSH_COLORS_LOADED=1

# Export color test function for easy access
autoload -Uz colors_Test colors_Available
