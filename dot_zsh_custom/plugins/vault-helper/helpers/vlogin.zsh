# Login to Vault
function vlogin {
    # Check that vault exists
    if [ $(command -v vault) ]; then; else
        echo "${_COLOR_RED}[!]${_RESET} vault must be installed to use vlogin!"
        return 1
    fi

    # Help text if -h is passed in
    if [[ $1 == -h* ]]; then
        echo "${_COLOR_CYAN}[i]${_RESET} vlogin [-t]"
        echo "${_COLOR_CYAN}[i]${_RESET}   -t: Print out token"
        return 1
    fi

    args="-no-print"
    
    # Print out token when -t is passed in
    if [[ $1 == -t* ]]; then            
        args="-field=token"
    fi

    # Perform Vault OIDC login using Authentik
    vault login -method=oidc $args
}
