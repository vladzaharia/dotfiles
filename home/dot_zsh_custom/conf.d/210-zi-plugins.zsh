######
### Group 210: ZI plugin manager and plugins
######

typeset -A ZI
ZI[BIN_DIR]="${HOME}/.zi"
source "${ZI[BIN_DIR]}/zi.zsh"

autoload -Uz _zi
(( ${+_comps} )) && _comps[zi]=_zi

######
### ZSH plugins (via ZI)
######

# Homebrew
zi ice wait lucid has'brew'
zi snippet OMZP::brew

# Docker
zi wait lucid has'docker' for \
  OMZP::docker \
  OMZP::docker-compose

# Git
zi ice wait lucid has'git'
zi snippet OMZP::git

# Pip
zi ice wait lucid has'pip'
zi snippet OMZP::pip

# Mac-specific
source $ZSH_CUSTOM/scripts/iterm2_shell_integration.zsh
zi ice wait lucid if'[[ $OSTYPE = darwin* ]]'
zi snippet OMZP::iterm2

# SSH + Mosh
zi ice wait lucid has'ssh'
zi snippet OMZP::ssh

zi ice wait lucid has'mosh'
zi snippet OMZP::mosh

# Colorization
zi wait lucid for \
  $ZSH_PLUGINS/zsh-256color \
  $ZSH_PLUGINS/colors \
  $ZSH_PLUGINS/colorize \
  OMZP::colored-man-pages

# Syntax highlighting / Autocompletion
zi wait lucid for \
  atinit"ZI[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
    $ZSH_PLUGINS/F-Sy-H \
  blockf \
    $ZSH_PLUGINS/zsh-completions

# Dotenv
zi snippet OMZP::dotenv

# ZBrowse
zi load $ZSH_PLUGINS/zui
zi load $ZSH_PLUGINS/zbrowse

# Eza
zi ice wait lucid has'eza'
zi light $ZSH_PLUGINS/zsh-eza

# Vault
zi ice wait lucid has'vault'
zi light $ZSH_PLUGINS/vault-helper

# Crypto (SOPS utilities)
zi ice wait lucid has'sops'
zi light $ZSH_PLUGINS/crypto

zi load $ZSH_PLUGINS/pkmn-repos
