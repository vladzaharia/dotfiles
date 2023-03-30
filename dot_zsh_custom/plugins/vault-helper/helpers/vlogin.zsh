# Login to Vault
# TODO: Add token return
function vlogin {
    if [ "$(command -v vault)" ]; then; else
        echo "${_COLOR_RED}[!] vault must be installed to use vlogin!${_RESET}"
        return 1
    fi

    vault login -method=oidc -no-print
}
