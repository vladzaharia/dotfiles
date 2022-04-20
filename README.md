# Dotfiles

Reproducible home setup using [chezmoi](https://www.chezmoi.io/).

## Prereqs

chezmoi will run a package install script on first run, and anytime dependencies change. The only prereq is [brew](https://brew.sh) for macOS.

## Bootstrapping

You can bootstrap the environment by downloading [the bootstrap file](https://raw.githubusercontent.com/vladzaharia/dotfiles/main/bootstrap.sh) and using `bootstrap.sh -g` which will download and install chezmoi and link it to this GitHub repository. 

Running `bootstrap.sh` without the flag will also download and install chezmoi, but link it to the local directory instead.

## GitPod / Codespaces support

GitPod and Codespaces are supported with a limited set of pre-installed software to keep startup times low. The `CODESPACES` and `GITPOD_WORKSPACE_ID` env variables are used to check if the dotfiles are executed in either environment.

## Installed Software

| Software | macOS | Debian | WSL | GitPod / Codespaces |
|----------|-------|--------|-----|---------------------|
| [oh-my-zsh](https://ohmyz.sh/)| ✅ | ✅| ✅| ✅|
| [Starship](https://starship.rs/) | ✅ | ✅| ✅| ✅|
| [Doppler](https://www.doppler.com/) | ✅ | ✅| ✅| ✅|
| [direnv](https://direnv.net/) | ✅ | ✅| ✅| ✅|
| [1password-cli](https://1password.com/downloads/command-line/) | ✅ | ✅| ⚠️ ||
| [docker](https://www.docker.com/)| ✅ | ✅| ✅||
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | ✅ | ✅| ✅||
| [azure-cli](https://docs.microsoft.com/en-us/cli/azure/) | ✅ | | ||
| [gitleaks](https://github.com/zricethezav/gitleaks)| ✅ | | ||
| [nvm](https://github.com/nvm-sh/nvm)| ✅ | | ||
| [step](https://smallstep.com/docs/step-cli)  | ✅ | | ||

## Secret Files

Some secret files (eg. `.ssh/id_rsa`, `.gnupg/*`) require 1Password to be set up and authenticated before being restored. The 1Password CLI is automatically installed on macOS and Linux, but requires authentication either through the 1Password App or manually.

Either [set up biometric unlock](https://developer.1password.com/docs/cli/get-started#turn-on-biometric-unlock) or [sign in manually](https://developer.1password.com/docs/cli/sign-in-manually) to properly restore these packages.
