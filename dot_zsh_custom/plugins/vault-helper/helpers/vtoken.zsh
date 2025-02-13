# Lookup token information and capabilities
function vtoken() {
    # Check that vault exists
    if [ $(command -v vault) ]; then; else
        echo "${_COLOR_RED}[!]${_RESET} vault must be installed to use vtoken!"
        return 1
    fi

    # Help text if no token is entered or -h is passed in
    if [[ $1 == -h* ]]; then
        echo "${_COLOR_CYAN}[i]${_RESET} vtoken <token> [<path>]"
        echo "${_COLOR_CYAN}[i]${_RESET}   <token>: Token to get informaiton for"
        echo "${_COLOR_CYAN}[i]${_RESET}   <path>: Check capabilities of token against path"
        return 1
    fi

    if [ $# -eq 0 ]; then
        # Token lookup
	    vault token lookup
    elif [ $# -eq 1 ]; then
        # Token lookup
	    vault token lookup $1
    elif [ $# -eq 2 ]; then
        # Token capability check against path
	    vault token capabilities $1 $2
    fi
}
