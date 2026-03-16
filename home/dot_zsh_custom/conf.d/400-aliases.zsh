######
### Group 400: Aliases and shortcuts
######

# ── Editor ───────────────────────────────────────────────────────
if command -v micro > /dev/null 2>&1; then
    alias nano=micro
fi

# ── Better cat ───────────────────────────────────────────────────
if command -v bat > /dev/null 2>&1; then
    alias cat=bat
    alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
    alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'
fi

# ── Better dig ───────────────────────────────────────────────────
if command -v doggo > /dev/null 2>&1; then
    alias dig=doggo
fi

# ── Better diff ──────────────────────────────────────────────────
if command -v difft > /dev/null 2>&1; then
    alias diff=difft
fi

# ── Navigation ───────────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

# ── Directory listing ────────────────────────────────────────────
if command -v eza > /dev/null 2>&1; then
    alias l='eza -la --icons --git'
    alias ll='eza -la --icons --git --long'
    alias lt='eza --tree --icons --git-ignore -I ".git|node_modules" --level=3'
    alias lr='eza -la --icons --git --sort=modified'
    alias lsize='eza -la --icons --git --sort=size'
fi

# ── Git ──────────────────────────────────────────────────────────
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gaa='git add --all'
alias gap='git add -p'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gcan='git commit --amend --no-edit'
alias gco='git checkout'
alias gcob='git checkout -b'
alias gsw='git switch'
alias gswc='git switch -c'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gd='git diff'
alias gds='git diff --staged'
# Semantic difftastic diffs
alias gdft='git dft'
alias gdlog='git dlog'
alias gdshow='git dshow'
alias gl='git log --oneline --decorate -20'
alias glg='git log --oneline --decorate --graph --all'
alias gf='git fetch --all --prune'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull'
alias gst='git stash'
alias gstp='git stash pop'
alias gstl='git stash list'

# ── Docker ───────────────────────────────────────────────────────
if command -v docker > /dev/null 2>&1; then
    alias d='docker'
    alias dps='docker ps'
    alias dpsa='docker ps -a'
    alias dimg='docker images'
    alias drm='docker rm'
    alias drmi='docker rmi'
    alias dlog='docker logs -f'
    alias dexec='docker exec -it'
    alias dprune='docker system prune -f'
    alias dvol='docker volume ls'
fi

if docker compose version > /dev/null 2>&1; then
    alias dc='docker compose'
    alias dcu='docker compose up -d'
    alias dcd='docker compose down'
    alias dcr='docker compose restart'
    alias dcl='docker compose logs -f'
    alias dcps='docker compose ps'
    alias dcb='docker compose build'
fi

# ── Network / System ─────────────────────────────────────────────
alias ports='ss -tulpn 2>/dev/null || netstat -tulpn'
alias myip='curl -s https://api.ipify.org && echo'
alias localip='ipconfig getifaddr en0 2>/dev/null || hostname -I | awk "{print \$1}"'

# ── Filesystem ───────────────────────────────────────────────────
alias df='df -h'
alias du='du -sh'
alias mkdir='mkdir -pv'
alias fhere='fd . --type f'
alias dhere='fd . --type d'

# ── Safety ───────────────────────────────────────────────────────
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# ── Misc / Productivity ──────────────────────────────────────────
alias reload='source ~/.zshrc'
alias zshrc='${EDITOR:-nano} ~/.zshrc'
alias path='echo $PATH | tr ":" "\n"'
alias cls='clear'
alias week='date +%V'
alias now='date "+%Y-%m-%d %H:%M:%S"'
alias timestamp='date "+%Y%m%d_%H%M%S"'

# ── Chezmoi ──────────────────────────────────────────────────────
alias cm='chezmoi'
alias cma='chezmoi apply'
alias cmd='chezmoi diff'
alias cme='chezmoi edit'
alias cms='chezmoi status'
alias cmcd='cd $(chezmoi source-path)'
