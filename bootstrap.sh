#!/bin/sh
# bootstrap.sh — install chezmoi and apply vladzaharia/dotfiles
#
# Usage:
#   One-liner (GitHub):  sh -c "$(curl -fsSL https://raw.githubusercontent.com/vladzaharia/dotfiles/main/bootstrap.sh)"
#   Local clone:         ./bootstrap.sh --local
#   Custom branch:       ./bootstrap.sh --branch=dev
#   Dry run:             ./bootstrap.sh --dry-run
#   Force HTTPS:         ./bootstrap.sh --https

set -eu

# ── Defaults ──────────────────────────────────────────────────────────────────
GITHUB_USER="vladzaharia"
SSH_REPO="git@github.com:vladzaharia/dotfiles.git"
HTTPS_REPO="https://github.com/vladzaharia/dotfiles.git"
BRANCH="main"
SOURCE=""       # empty = use GitHub
DRY_RUN=0
FORCE=1
USE_HTTPS=0
MAX_RETRIES=3
RETRY_DELAY=5

# ── Colors ────────────────────────────────────────────────────────────────────
CYAN='\033[0;36m'
LCYAN='\033[1;36m'
RED='\033[0;31m'
RESET='\033[0m'

info()  { printf "${LCYAN}###${RESET} %s\n" "$*"; }
step()  { printf "${CYAN}  →${RESET} %s\n"  "$*"; }
error() { printf "${RED}✗${RESET} %s\n" "$*" >&2; }

# ── Argument parsing ──────────────────────────────────────────────────────────
for arg in "$@"; do
    case "$arg" in
        --local)        SOURCE="$(cd "$(dirname "$0")" && pwd)" ;;
        --branch=*)     BRANCH="${arg#*=}" ;;
        --dry-run)      DRY_RUN=1 ;;
        --no-force)     FORCE=0 ;;
        --https)        USE_HTTPS=1 ;;
        --retries=*)    MAX_RETRIES="${arg#*=}" ;;
        -h|--help)      grep '^#' "$0" | head -10 | sed 's/^# \?//'; exit 0 ;;
        *)              error "Unknown option: $arg"; exit 1 ;;
    esac
done

# ── Container/ephemeral detection → use HTTPS ─────────────────────────────────
is_container() {
    [ -n "${DEVPOD:-}" ] || [ -n "${GITPOD_WORKSPACE_ID:-}" ] || \
    [ -n "${CODESPACES:-}" ] || [ -n "${CODER_ENV:-}" ] || \
    [ -f "/.dockerenv" ] || [ -d "/home/kasm-default-profile" ]
}

if [ "${USE_HTTPS}" -eq 1 ] || is_container; then
    REPO_URL="${HTTPS_REPO}"
    step "Container detected (or --https) — using HTTPS clone"
else
    REPO_URL="${SSH_REPO}"
    step "Using SSH clone (pass --https to override)"
fi

# ── Retry helper ──────────────────────────────────────────────────────────────
retry() {
    local n=0
    until [ "$n" -ge "$MAX_RETRIES" ]; do
        "$@" && return 0
        n=$((n + 1))
        [ "$n" -lt "$MAX_RETRIES" ] && {
            error "Failed (attempt $n/$MAX_RETRIES), retrying in ${RETRY_DELAY}s…"
            sleep "$RETRY_DELAY"
        }
    done
    error "Failed after $MAX_RETRIES attempts: $*"
    return 1
}

# ── Install chezmoi if missing ────────────────────────────────────────────────
BIN_DIR="${HOME}/.local/bin"
export PATH="${BIN_DIR}:${PATH}"

if ! command -v chezmoi > /dev/null 2>&1; then
    info "Installing chezmoi"
    mkdir -p "$BIN_DIR"
    if command -v curl > /dev/null 2>&1; then
        retry sh -c "$(curl -fsLS https://chezmoi.io/get)" -- -b "$BIN_DIR"
    elif command -v wget > /dev/null 2>&1; then
        retry sh -c "$(wget -qO- https://chezmoi.io/get)" -- -b "$BIN_DIR"
    else
        error "curl or wget is required to install chezmoi"
        exit 1
    fi
    step "chezmoi installed to ${BIN_DIR}/chezmoi"
else
    step "chezmoi already installed: $(chezmoi --version)"
fi

# ── Build chezmoi args ────────────────────────────────────────────────────────
CHEZMOI_ARGS="--apply"
[ "$FORCE"   -eq 1 ] && CHEZMOI_ARGS="$CHEZMOI_ARGS --force"
[ "$DRY_RUN" -eq 1 ] && CHEZMOI_ARGS="$CHEZMOI_ARGS --dry-run"

# ── Run chezmoi init ──────────────────────────────────────────────────────────
if [ -n "$SOURCE" ]; then
    info "Initializing from local source: $SOURCE"
    chezmoi init $CHEZMOI_ARGS "--source=$SOURCE"
else
    info "Initializing from GitHub: $REPO_URL @ $BRANCH"
    chezmoi init $CHEZMOI_ARGS --branch="$BRANCH" --ssh-command="$REPO_URL" "$GITHUB_USER" 2>/dev/null || \
    chezmoi init $CHEZMOI_ARGS --branch="$BRANCH" "$GITHUB_USER"
fi

step "Bootstrap complete. System tools will be preferred on next apply or shell restart."
