# Lookup token information and capabilities
function vtoken() {
    if [ "$(command -v vault)" ]; then; else
        echo "${_COLOR_RED}[!]${_RESET} vault must be installed to use vtoken!"
        return 1
    fi

    if [ $# -eq 0 ] || [[ $1 == -h* ]]; then
        if [ $# -eq 0 ]; then
            echo "${_COLOR_RED}[!]${_RESET} Must provide token!"
            echo ""
        fi

        echo "${_COLOR_CYAN}[i]${_RESET} vtoken <token> [<path>]"
        echo "${_COLOR_CYAN}[i]${_RESET} <token>: Token to get informaiton for"
        echo "${_COLOR_CYAN}[i]${_RESET}  <path>: Check capabilities of token against path"
        return 1
    fi

    if [ $# -eq 1 ]; then
	    vault token lookup $1
    elif [ $# -eq 2 ]; then
	    vault token capabilities $1 $2
    fi
}
