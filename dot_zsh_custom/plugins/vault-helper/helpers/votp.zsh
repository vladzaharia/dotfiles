# Generate OTP code
# TODO: add list
function votp() {
    if [ "$(command -v vault)" ]; then; else
        echo "${_COLOR_RED}[!] vault must be installed to use votp!${_RESET}"
        return 1
    fi

    if [ $# -eq 0 ]; then
        echo "${_COLOR_RED}[!] Must provide TOTP key!${_RESET}"
        return 1
    fi

    vault read -field=code totp/code/$1
}