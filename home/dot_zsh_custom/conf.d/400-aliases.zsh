######
### Group 400: Aliases and shortcuts
######

# Editor
if command -v micro > /dev/null 2>&1; then
    alias nano=micro
fi

# Better cat
if command -v bat > /dev/null 2>&1; then
    alias cat=bat
    alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
    alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'
fi

# Better cd
if command -v zoxide > /dev/null 2>&1; then
    alias cd=z
fi
