# Lookup token information and capabilities
function vtoken() {
    if [ "$(command -v vault)" ]; then; else
        echo "${_COLOR_RED}[!] vault must be installed to use vtoken!${_RESET}"
        return 1
    fi

    if [ $# -eq 0 ]; then
        echo "${_COLOR_RED}[!] Must provide token, optionally with path to check!${_RESET}"
        return 1
    fi

    if [ $# -eq 1 ]; then
	    vault token lookup $1
    elif [ $# -eq 2 ]; then
	    vault token capabilities $1 $2
    fi
}
