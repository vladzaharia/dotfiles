#!/bin/sh
# check.sh — render all chezmoi templates and report errors
# Run this before 'chezmoi apply' to catch template issues early.
# Usage: ./check.sh [--verbose]

VERBOSE=0
[ "${1:-}" = "--verbose" ] && VERBOSE=1

SOURCE="$(cd "$(dirname "$0")/home" && pwd)"
PASS=0
FAIL=0

check() {
    local label="$1"
    local file="$2"
    local out err

    err=$(chezmoi execute-template < "$file" 2>&1 >/dev/null)
    if [ $? -eq 0 ]; then
        PASS=$((PASS + 1))
        [ "$VERBOSE" -eq 1 ] && printf "  ✓ %s\n" "$label"
    else
        FAIL=$((FAIL + 1))
        printf "  ✗ %s\n" "$label"
        printf "    %s\n" "$err"
    fi
}

check_output() {
    local label="$1"
    local file="$2"
    local out err

    out=$(chezmoi execute-template < "$file" 2>&1)
    if [ $? -eq 0 ]; then
        PASS=$((PASS + 1))
        if [ "$VERBOSE" -eq 1 ]; then
            printf "  ✓ %s\n" "$label"
            printf "%s\n" "$out" | sed 's/^/    /'
        fi
    else
        FAIL=$((FAIL + 1))
        printf "  ✗ %s\n" "$label"
        printf "%s\n" "$out" | sed 's/^/    /'
    fi
}

printf "=== chezmoi template check ===\n\n"

printf "[ Config ]\n"
printf "  ~ chezmoi.toml.tmpl (skipped — uses config-only functions; test with: chezmoi data)\n"

printf "\n[ Install scripts ]\n"
check "10-install-darwin"   "$SOURCE/run_onchange_before_10-install-darwin.sh.tmpl"
check "20-install-debian"   "$SOURCE/run_onchange_before_20-install-debian.sh.tmpl"
check "30-install-suse"     "$SOURCE/run_onchange_before_30-install-suse.sh.tmpl"
check "05-cleanup"          "$SOURCE/run_onchange_before_05-cleanup.sh.tmpl"
check "90-prefer-system"    "$SOURCE/run_onchange_after_90-prefer-system-tools.sh.tmpl"
check "00-get-age-key"      "$SOURCE/run_once_before_00-get-age-key.sh.tmpl"

printf "\n[ Dotfiles ]\n"
check "zshrc"               "$SOURCE/dot_zshrc.tmpl"
check "bashrc"              "$SOURCE/dot_bashrc.tmpl"
check "gitconfig"           "$SOURCE/dot_gitconfig.tmpl"
check "Brewfile"            "$SOURCE/Brewfile.tmpl"

printf "\n[ zsh conf.d ]\n"
for f in "$SOURCE"/dot_zsh_custom/conf.d/*.tmpl; do
    check "$(basename "$f")" "$f"
done

printf "\n[ dot_config ]\n"
for f in "$SOURCE"/dot_config/**/*.tmpl; do
    check "$(basename "$f")" "$f"
done

printf "\n"
if [ "$FAIL" -eq 0 ]; then
    printf "✓ All %d templates OK\n" "$PASS"
else
    printf "✗ %d failed, %d passed\n" "$FAIL" "$PASS"
    exit 1
fi
