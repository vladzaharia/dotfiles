ENV_INJECTED_COMMANDS=("compose up") # Do NOT add commas here

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

    setopt null_glob

    # Verify if the command we're running needs env interception
    _check_command_needs_env $@
    needsEnv=$?
    
    # Decrypt env files if needed
    if [[ $needsEnv == 1 ]]; then
      # Login using Vault Approle helper if needed
      _vault_approle_login

      # Decrupt all env files with SOPS/Vault/age
      _sops_decrypt

      # Check to make sure we decrypted successfully
      for file in *.env; do
        if (cat $file | grep -qEx -e 'sops_version=[0-9]+\.[0-9]+\.[0-9]+') ; then
          echo "${_COLOR_RED}[!]${_RESET} Env file(s) were not successfully decrypted!"
          return 1
        fi
      done
    fi

    # Run docker subcommand
    docker $@

    # Re-encrypt env files if needed
    if [[ $needsEnv == 1 ]]; then
      _sops_encrypt
    fi
}

function _check_command_needs_env {
  for command in $ENV_INJECTED_COMMANDS; do
    if [[ $@ =~ $command ]]; then
      return 1
    fi
  done

  return 0
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

function _sops_decrypt {
    echo "${_COLOR_CYAN}[i]${_RESET} Running decryption on env files..."
    for file in *.env; do
      if (cat $file | grep -qEx -e 'sops_version=[0-9]+\.[0-9]+\.[0-9]+') ; then
        sops decrypt -i $file
      else
        echo "${_COLOR_YELLOW}[!]${_RESET} $file does not need decryption!"
      fi
    done
}

function _sops_encrypt {
    echo "${_COLOR_CYAN}[i]${_RESET} Running encryption on env files..."
    for file in *.env; do
      if ! (cat $file | grep -qEx -e 'sops_version=[0-9]+\.[0-9]+\.[0-9]+') ; then
        sops encrypt -i $file
      else
        echo "${_COLOR_YELLOW}[!]${_RESET} $file does not need encryption!"
      fi
    done
}

# Make vdocker the default when running `docker`
alias docker=vdocker