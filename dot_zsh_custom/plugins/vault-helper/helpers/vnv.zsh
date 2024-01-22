# Inject environment variables for a project automatically
function vnv() {
    # Check that vault exists
    if [ $(command -v vault) ]; then; else
        echo "${_COLOR_RED}[!]${_RESET} vault must be installed to use vnv!"
        return 1
    fi

    # Help text if -h is passed in
    if [[ $1 == -h* ]]; then
        echo "${_COLOR_CYAN}[i]${_RESET} vnv [-c] <project>"
        echo "${_COLOR_CYAN}[i]${_RESET} project: Project to get dotenv variables for"
        echo "${_COLOR_CYAN}[i]${_RESET}      -c: Cleanup environment variables for project"
        return 1
    fi

    # Determine project to use, defaults to current working directory
    local vaultProject=$1
    if [ $# -eq 0 ]; then
        vaultProject=${PWD##*/}
        echo "${_COLOR_YELLOW}[!]${_RESET} No project was specified, using current directory '$vaultProject'"
    fi

    # Clean up set environment variables if -c is passed in
    if [[ $1 == -c* ]]; then
        vaultProject=$2
        echo "${_COLOR_YELLOW}[!]${_RESET} -c provided, cleaning environment variables for '$vaultProject'"
    else
        echo "${_COLOR_CYAN}[i]${_RESET} Injecting variables from dotenv/$vaultProject/dev"
    fi

    # Get JSON at dotenv/<project>/dev and parse out contents as key=value array
    local json=$(vault read -format=raw dotenv/$vaultProject/dev)
    local envVars=($(echo $json | jq -r '.data | to_entries | map(.key+"="+.value) | @sh'))

    for envVar in $envVars; do
        local exportStr=$(echo $envVar | tr -d "'")
        local key=$(echo $exportStr | cut -d "=" -f 1)

        if [[ $1 == -c* ]]; then
            # Clean up by unsetting key
            unset $key
            echo "${_COLOR_GREEN}[✓]${_RESET} Finished cleaning up $key"
        else
            # Export environment variable
            export $exportStr
            echo "${_COLOR_GREEN}[✓]${_RESET} Finished injecting $key"
        fi
    done
}