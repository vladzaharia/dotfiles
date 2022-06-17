#!/bin/sh

set -e # -e: exit on error

export PATH=$PATH:$HOME/.local/bin

if [ ! "$(command -v vault)" ]; then
  bin_dir="$HOME/.local/bin"
  sh -c "$(wget https://raw.github.com/robertpeteuil/vault-installer/master/vault-install.sh)"
  chmod +x ./vault-install.sh
  ./vault-install.sh -c
  mv vault "$bin_dir/vault"
  rm vault*
fi

if [ ! "$(command -v chezmoi)" ]; then
  bin_dir="$HOME/.local/bin"
  chezmoi="$bin_dir/chezmoi"
  if [ "$(command -v curl)" ]; then
    sh -c "$(curl -fsLS https://chezmoi.io/get)" -- -b "$bin_dir"
  elif [ "$(command -v wget)" ]; then
    sh -c "$(wget -qO- https://chezmoi.io/get)" -- -b "$bin_dir"
  else
    echo "To install chezmoi, you must have curl or wget installed." >&2
    exit 1
  fi
else
  chezmoi=chezmoi
fi

# POSIX way to get script's dir: https://stackoverflow.com/a/29834779/12156188
script_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"
# exec: replace current process with chezmoi init

if [ "$1" = "-g" ]; then
  exec "$chezmoi" init --apply vladzaharia
else
  exec "$chezmoi" init --apply "--source=$script_dir"
fi
