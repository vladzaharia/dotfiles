# Generate OTP code
function votp() {
    # Check that vault exists
    if [ $(command -v vault) ]; then; else
        echo "${_COLOR_RED}[!]${_RESET} vault must be installed to use votp!"
        return 1
    fi

    # Help text if no OTP key is entered or -h is passed in
    if [ $# -eq 0 ] || [[ $1 == -h* ]]; then
        if [ $# -eq 0 ]; then
            echo "${_COLOR_RED}[!]${_RESET} Must provide TOTP key!"
            echo ""
        fi
        
        echo "${_COLOR_CYAN}[i]${_RESET} votp [-l] <key>"
        echo "${_COLOR_CYAN}[i]${_RESET}   key: TOTP key to retrieve token for"
        echo "${_COLOR_CYAN}[i]${_RESET}   -l: List all keys"
        return 1
    fi

    if [[ $1 == -l* ]]; then
        echo "${_COLOR_YELLOW}[!]${_RESET} -l passed in, listing keys"
        
        # List all possible OTP keys
        vault list totp/keys
    else
        # Get OTP code for passed in key
        vault read -field=code totp/code/$1
    fi
}