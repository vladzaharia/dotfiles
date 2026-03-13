# dotfiles

Personal home setup via [chezmoi](https://www.chezmoi.io/).

## Quick Start

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/vladzaharia/dotfiles/main/bootstrap.sh)"
```

On first run, chezmoi will ask which **identity** (personal/pkmn) and **package groups** to install,
then fetch your age encryption key from 1Password automatically.

### Options

| Flag | Description |
|------|-------------|
| `--dry-run` | Preview changes without applying |
| `--local` | Use local clone instead of GitHub |
| `--branch=<branch>` | Use a specific git branch |
| `--https` | Force HTTPS clone (auto-set in containers) |
| `--retries=<n>` | Network retry attempts (default: 3) |

Clones via **SSH** by default (easy for ongoing updates). Automatically switches to **HTTPS** in containers/ephemeral environments where no SSH key is present.

## Platforms

| Platform | Status | Notes |
|----------|--------|-------|
| macOS (Apple Silicon) | ✅ | Full support |
| macOS (Intel) | ✅ | Full support |
| Debian / Ubuntu | ✅ | Full support |
| openSUSE | ✅ | Full support |
| Windows | ⚠️ | Config files only |
| WSL | ⚠️ | No biometric 1Password |
| Ephemeral (GitPod/Codespaces) | ⚠️ | Minimal install, no secrets |

## Package Groups

Selected interactively on first run via `promptMultichoiceOnce`. `core` always installs. macOS workstation groups (`apps`, `gaming`, `creative`, `comms`) only offered on macOS workstations.

| Group | Platforms | Contents |
|-------|-----------|----------|
| `core` | **All** | Always installed: bat, eza, fd, micro, mise, ripgrep, zoxide, chezmoi… |
| `dev` | **All** CLI + macOS GUI | All: gh, git-lfs, docker, oh-my-posh; macOS: WaveTerm, VS Code, Zed, DevPod, Requestly |
| `cloud` | **All** | vault, terraform |
| `ai` | **All** CLI + macOS GUI | macOS: Claude app, LM Studio, Plaud, omi; All: Claude Code, Ollama, LSP servers |
| `security` | **All** CLI + macOS GUI | All: sops, gnupg; macOS: 1Password app + CLI, Tailscale, Pangolin, UniFi |
| `apps` | macOS workstation | Raycast, Obsidian, Rectangle Pro, DaisyDisk, Dropshare, HomeKit, Kagi |
| `gaming` | macOS workstation | Steam, Parsec, Moonlight, Jump Desktop |
| `creative` | macOS workstation | Bambu Studio, Affinity suite\*, Infuse |
| `comms` | macOS workstation | Discord; Zoom (pkmn only) |
| `pkmn` | **All** (pkmn identity) | Work-specific tools |

\* Affinity casks deprecated 2026-10-30 — migration to App Store needed at that point.

> **Ephemeral environments** (Codespaces, GitPod, Coder, DevPod): no prompts, no packages installed, no secrets — minimal dotfiles only.

To add machine-local packages, edit `~/.config/chezmoi/chezmoi.toml`:
```toml
[data]
  extra_packages.darwin.brew = ["neovim"]
  disabled_packages = ["hurl"]
```

## Secrets

Age encryption keys are stored in 1Password and fetched automatically on init via the 1Password CLI.
On macOS with 1Password app, this uses Touch ID / system auth — no passphrase prompts.
Encrypted files: SSH keys, GPG keyring, pkmn-specific configs.
