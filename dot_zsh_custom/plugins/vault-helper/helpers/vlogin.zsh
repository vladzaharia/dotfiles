# Login to Vault
function vlogin {
    if [ "$(command -v vault)" ]; then; else
        echo "${_COLOR_RED}[!]${_RESET} vault must be installed to use vlogin!"
        return 1
    fi

    if [[ $1 == -h* ]]; then
        echo "${_COLOR_CYAN}[i]${_RESET} vlogin [-t]"
        echo "${_COLOR_CYAN}[i]${_RESET} -t: Print out token"
        return 1
    fi

    args="-no-print"
    
    if [[ $1 == -t* ]]; then            
        args="-field=token"
    fi

    vault login -method=oidc $args
}
