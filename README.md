# Dotfiles

Reproducible home setup using [chezmoi](https://www.chezmoi.io/).

## Prerequisites

chezmoi will run a package install script on first run, and anytime dependencies change. 

## Supported Platforms

- ✅ macOS (Apple or Intel)
    - [brew](https://brew.sh) is required to download packages
- ✅ Debian / Ubuntu
- ⚠️ Windows
    - Only some settings are supported
- ⚠️ WSL Debian / Ubuntu
    - Biometric 1Password authentication not available
- ⚠️ Ephemeral workspaces (GitPod / Codespaces)
    - Minimal package installation to reduce startup time
    - No access to secret files

## Bootstrapping

You can bootstrap the environment by downloading [the bootstrap file](https://raw.githubusercontent.com/vladzaharia/dotfiles/main/bootstrap.sh) and using `bootstrap.sh -g` which will download and install chezmoi and link it to this GitHub repository. 

Running `bootstrap.sh` without the flag will also download and install chezmoi, but link it to the local directory instead.

## Installed Software

| Software | macOS | Debian | WSL | GitPod / Codespaces |
|----------|-------|--------|-----|---------------------|
| [oh-my-zsh](https://ohmyz.sh/)| ✅ | ✅ | ✅ | ✅ |
| [Starship](https://starship.rs/) | ✅ | ✅ | ✅ | ✅ |
| [direnv](https://direnv.net/) | ✅ | ✅ | ✅ | ✅ |
| [1password-cli](https://1password.com/downloads/command-line/) | ✅ | ✅ | ✅ | |
| [docker](https://www.docker.com/)| ✅ | ✅ | ✅ | |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | ✅ | ✅ | ✅ | |
| [azure-cli](https://docs.microsoft.com/en-us/cli/azure/) | ✅ | | | |
| [nvm](https://github.com/nvm-sh/nvm)| ✅ | | | |

## Secret Files

The following files are stored and retrieved via 1Password:

- `.ssh/id_rsa`
- `.gnupg/pubring.kbx`
- `.gnupg/trustdb.gpg`

chezmoi will automatically download and install the 1Password CLI on supported platforms, and will wait until 1Password is available before attempting to restore the secret files.

After chezmoi installs packages, either [set up biometric unlock](https://developer.1password.com/docs/cli/get-started#turn-on-biometric-unlock) or [sign in manually](https://developer.1password.com/docs/cli/sign-in-manually).

Once complete, open a new console to allow zsh to find 1Password and set the flag stating it's available. Run `chezmoi init` again to restore the secret files with the stored session.