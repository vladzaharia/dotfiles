# SSH to remote machine using Vault SSH certificate
function vmosh() {
    # Check that vault exists
    if [ $(command -v vault) ]; then; else
        echo "${_COLOR_RED}[!]${_RESET} vault must be installed to use vmosh!"
        return 1
    fi

    if [ $(command -v mosh) ]; then
        MOSH_BIN=$(command -v mosh)
    else
        echo "${_COLOR_RED}[!]${_RESET} vault must be installed to use vmosh!"
        return 1
    fi
    
    # Help text if no hostname is entered or -h is passed in
    if [ $# -eq 0 ] || [[ $1 == -h* ]]; then
        if [ $# -eq 0 ]; then
            echo "${_COLOR_RED}[!]${_RESET} Must provide hostname!"
            echo ""
        fi

        echo "${_COLOR_CYAN}[i]${_cRESET} vmosh [-r] [username@]<hostname>"
        echo "${_COLOR_CYAN}[i]${_RESET}   hostname: Computer to connect to"
        echo "${_COLOR_CYAN}[i]${_RESET}   username: User to connect as, defaults to your own"
        echo "${_COLOR_CYAN}[i]${_RESET}         -r: Connect as root"
	    return 1
    fi

    # Set default values
    local vaultMode=ca
    local vaultRole=user
    local username=$USER
    local hostname=$1

    # Find public key
    _vmosh_find_key
    echo "${_COLOR_BLUE}[i]${_RESET} Using public key $HOME/.ssh/$sshKey.pub"

    # Determine if we should be connecting as root
    if [[ $1 == -r* ]] || [[ $3 == -r* ]]; then
        echo "${_COLOR_YELLOW}[!]${_RESET} -r passed in, connecting as root"
            
        vaultRole=root
        username=root
        hostname=$2
    fi

    local connString=$username@$hostname
    # Check if full connection string was passed in
    if [[ $hostname == *@* ]]; then
        connString=$hostname
    fi

    # Execute vault
    vault ssh -mode=$vaultMode -role=$vaultRole -public-key-path="$HOME/.ssh/$sshKey.pub" -private-key-path="$HOME/.ssh/$sshKey" -ssh-executable="$MOSH_BIN" $connString 
}

function _vmosh_find_key() {
    # All possible key file names
    local possibleKeys=(id_rsa id_ecdsa id_ed25519 id_dsa id_pkmn)

    for possibleKey in $possibleKeys; do
        # Check if key exists
        if [ -f "$HOME/.ssh/$possibleKey.pub" ]; then
            sshKey=$possibleKey
            return
        fi
    done
}