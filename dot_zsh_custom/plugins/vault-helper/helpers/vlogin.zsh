# Login to Vault
function vlogin {
    if [ "$(command -v vault)" ]; then; else
        echo "${_COLOR_RED}[!] vault must be installed to use vlogin!${_RESET}"
        return 1
    fi

    args="-no-print"
    
    if [[ $1 == -t* ]]; then            
        args="-field=token"
    fi

    vault login -method=oidc $args
}
