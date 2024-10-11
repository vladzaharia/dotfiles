# Docker-with-Vault utility
function vdocker {
    # Check that vault exists
    if [ $(command -v vault) ]; then; else
        echo "${_COLOR_RED}[!]${_RESET} vault must be installed to use vdocker!"
        return 1
    fi

    # Help text if -h is passed in
    if [[ $1 == -h* ]]; then
        echo "${_COLOR_CYAN}[i]${_RESET} vdocker [args]"
        echo "${_COLOR_CYAN}[i]${_RESET}   See \`man docker\` for more information."
        return 1
    fi

    # Login using Vault Approle helper
    _vault_approle_login

    # Decrupt all env files with SOPS/Vault/age
    _sops_decrypt_files

    docker $@

    # Re-encrypt all env files with SOPS/Vault/age
    _sops_encrypt_files
}

# Login to Vault using approle if needed
function _vault_approle_login {
    # Check if existing token still works
    vault token lookup &> /dev/null
    
    if [ $? -ne 0 ]; then
      token=$(vault write -field="token" auth/approle/login role_id="xxx" secret_id="xxx")
      export VAULT_TOKEN=$token
    fi   
}

function _sops_decrypt_files {
    find . -type f -name "*.env" -maxdepth 0 -exec sops decrypt "{}" \;
}

function _sops_encrypt_files {
    find . -type f -name "*.env" -maxdepth 0 -exec sops encrypt "{}" \;
}