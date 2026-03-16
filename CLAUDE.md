# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Personal dotfiles managed by [chezmoi](https://www.chezmoi.io/). The `home/` directory is the chezmoi source directory — files here are templates that get rendered and applied to `$HOME`.

## Key Commands

```sh
# Preview what would change (safe, no writes)
chezmoi diff

# Apply dotfiles to $HOME
chezmoi apply

# Validate all templates before applying
./check.sh
./check.sh --verbose   # show rendered output for passing templates

# Re-render chezmoi.toml interactively (identity/package prompts)
chezmoi init --source=.

# Inspect the resolved data context
chezmoi data
```

## File Naming Conventions (chezmoi)

| Prefix/Suffix | Meaning |
|---|---|
| `dot_` | Becomes `.` (e.g. `dot_zshrc` → `~/.zshrc`) |
| `.tmpl` | Go template — rendered via `chezmoi execute-template` |
| `run_once_before_*` | Shell script run once at init |
| `run_onchange_before_*` | Shell script re-run when its content changes |
| `run_onchange_after_*` | Shell script re-run after apply when content changes |
| `encrypted_` | Age-encrypted file |
| `private_` | File/dir with mode 0600 |

## Architecture

### Config & Data

- **`home/.chezmoi.toml.tmpl`** — Master config template. Runs in two phases: (1) auto-detects environment (ephemeral/WSL/chassis type), (2) interactive prompts via `promptMultichoiceOnce` / `promptChoiceOnce`. Emits `chezmoi.toml` with `[data]` block used by all other templates. Prompts are cached — re-run `chezmoi init` to change selections.
- **`home/.chezmoidata/packages.toml`** — Package group definitions. Consumed by install scripts via `.packages.<group>.<platform>.<key>`. Adding a new package: add it here, install scripts pick it up automatically.

### Install Scripts

- **`run_onchange_before_10-install-darwin.sh.tmpl`** — macOS (Homebrew + mas). Helper functions `brew_formula`, `brew_cask`, `mas_install` handle idempotency. Iterates `.package_groups` from config data.
- **`run_onchange_before_20-install-debian.sh.tmpl`** — Debian/Ubuntu (apt).
- **`run_onchange_before_30-install-suse.sh.tmpl`** — openSUSE (zypper).
- **`run_onchange_before_05-cleanup.sh.tmpl`** — Removes stale symlinks / old config before apply.
- **`run_onchange_after_90-prefer-system-tools.sh.tmpl`** — Relinks system tools over Homebrew shims when both exist.

### Shell Config (`home/dot_zsh_custom/`)

Loaded numerically by `dot_zshrc.tmpl`:

| File | Purpose |
|---|---|
| `conf.d/100-path.zsh.tmpl` | PATH setup |
| `conf.d/200-omz.zsh.tmpl` | Oh My Zsh config |
| `conf.d/210-zi-plugins.zsh` | Zi plugin loader |
| `conf.d/300-tools.zsh.tmpl` | Tool initialisation (mise, zoxide, atuin…) |
| `conf.d/310-docker.zsh.tmpl` | Docker runtime aliases (orbstack/colima/docker-desktop) |
| `conf.d/400-aliases.zsh` | Shell aliases |
| `conf.d/500-pkmn.zsh.tmpl` | Work-identity extras (guarded by `.flags.pokemon`) |
| `conf.d/900-prompt.zsh.tmpl` | oh-my-posh prompt |
| `lib/` | Shared zsh helpers (sourced by conf.d) |
| `plugins/` | Custom plugins: `auto-nvmrc`, `crypto`, `vault-helper` |

### Template Variables

All templates can reference these from `chezmoi data`:

| Variable | Values |
|---|---|
| `.chezmoi.os` | `darwin` / `linux` / `windows` |
| `.chezmoi.arch` | `arm64` / `amd64` |
| `.chezmoi.chassis` | `laptop` / `desktop` / `server` / `ephemeral` / `wsl` / `beepy` |
| `.chezmoi.distro.name` | `ubuntu` / `debian` / `opensuse` / etc. |
| `.chezmoi.distro.like` | `debian` / `opensuse` / etc. |
| `.flags.ephemeral` | `true` in Codespaces/GitPod/Coder/DevPod |
| `.flags.pokemon` | `true` when pkmn identity is active |
| `.flags.applesilicon` | `true` on macOS arm64 |
| `.package_groups` | List of selected groups e.g. `["dev","ai","security"]` |
| `.packages` | Full package definitions from `packages.toml` |
| `.docker.runtime` | `orbstack` / `colima` / `docker-desktop` / `none` |

### Secrets

Age-encrypted files (prefix `encrypted_`) require a key in `~/.keys/personal.key` or `~/.keys/pkmn.key`. Keys are stored in 1Password and fetched by `run_once_before_00-get-age-key.sh.tmpl` at init. Without the key, `chezmoi apply` will fail on encrypted files.

## Adding Packages

Edit `home/.chezmoidata/packages.toml` — add to the appropriate group and platform key (`brew`, `cask`, `apt`, `zypper`, `mas`, `npm_global`, `go_install`). The install scripts iterate this data automatically; no script edits needed for standard packages.

## Ephemeral Environments

When `flags.ephemeral` is true (Codespaces, GitPod, Coder, DevPod, WSL, Kasm):
- No prompts run — all selections default to empty/minimal
- Install scripts produce no-op output (empty package groups)
- Encrypted files are skipped (no age key)
- Only non-secret dotfiles are applied
