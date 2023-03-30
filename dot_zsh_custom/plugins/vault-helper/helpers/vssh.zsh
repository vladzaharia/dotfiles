# SSH to remote machine using Vault SSH certificate
function vssh() {
    if [ "$(command -v vault)" ]; then; else
        echo "${_COLOR_RED}[!] vault must be installed to use vlogin!${_RESET}"
        return 1
    fi

    if [ $# -eq 0 ]; then
        echo "${_COLOR_RED}[!] Must provide hostname!${_RESET}"
	    return 1
    fi

    mode=ca
    role=user
    username=$USER
    host=$1

    if [[ $1 == -r* ]]; then
        echo "${_COLOR_YELLOW}[i] Connecting as root${_RESET}"
            
        role=root
        username=root
        host=$2
    fi
    vault ssh -mode=$mode -role=$role $username@$host
}