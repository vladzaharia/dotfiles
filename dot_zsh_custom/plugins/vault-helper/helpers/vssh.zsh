# SSH to remote machine using Vault SSH certificate
function vssh() {
    if [ "$(command -v vault)" ]; then; else
        echo "${_COLOR_RED}[!]${_RESET} vault must be installed to use vssh!"
        return 1
    fi

    if [ $# -eq 0 ] || [[ $1 == -h* ]]; then
        if [ $# -eq 0 ]; then
            echo "${_COLOR_RED}[!]${_RESET} Must provide hostname!"
            echo ""
        fi
        
        echo "${_COLOR_CYAN}[i]${_RESET} vssh [-r] <hostname>"
        echo "${_COLOR_CYAN}[i]${_RESET} hostname: Computer to connect to"
        echo "${_COLOR_CYAN}[i]${_RESET}       -r: Connect as root"
	    return 1
    fi

    mode=ca
    role=user
    username=$USER
    host=$1

    if [[ $1 == -r* ]]; then
        echo "${_COLOR_YELLOW}[!]${_RESET} -r passed in, connecting as root"
            
        role=root
        username=root
        host=$2
    fi
    vault ssh -mode=$mode -role=$role $username@$host
}