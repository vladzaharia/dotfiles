# Inject environment variables for a project automatically
function vnv() {
    if [ "$(command -v vault)" ]; then; else
        echo "${_COLOR_RED}[!]${_RESET} vault must be installed to use vnv!"
        return 1
    fi

    if [[ $1 == -h* ]]; then
        echo "${_COLOR_CYAN}[i]${_RESET} vnv [-c] <project>"
        echo "${_COLOR_CYAN}[i]${_RESET} project: Project to get dotenv variables for"
        echo "${_COLOR_CYAN}[i]${_RESET}      -c: Cleanup environment variables for project"
        return 1
    fi

    project=$1
    if [ $# -eq 0 ]; then
        project=${PWD##*/}
        echo "${_COLOR_YELLOW}[!]${_RESET} No project was specified, using current directory '$project'"
    fi

    if [[ $1 == -c* ]]; then
        project=$2
        echo "${_COLOR_YELLOW}[!]${_RESET} -c provided, cleaning environment variables for '$project'"
    else
        echo "${_COLOR_CYAN}[i]${_RESET} Injecting variables from dotenv/$project/dev"
    fi

    local json_out=$(vault read -format=raw dotenv/$project/dev)
    local parsed=($(echo $json_out | jq -r '.data | to_entries | map(.key+"="+.value) | @sh'))

    for envvar in $parsed; do
        exported=$(echo $envvar | tr -d "'")
        key=$(echo $exported | cut -d "=" -f 1)

        if [[ $1 == -c* ]]; then
            unset $key
            echo "${_COLOR_GREEN}[✓]${_RESET} Finished cleaning up $key"
        else
            export $exported
            echo "${_COLOR_GREEN}[✓]${_RESET} Finished injecting $key"
        fi
    done
}