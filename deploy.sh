#!/usr/bin/env bash
set -euo pipefail

hostname=$(hostname)

# Check if hostname matches any of the specified names
if [[ "$hostname" =~ ^(workstation|laptop|steamdeck)$ ]]; then
  if [[ ! -f baserom.us.z64 ]]; then
    echo "Skipping baserom.us.z64 import: file not found."
  else
    nix-store --add-fixed sha256 baserom.us.z64
  fi
fi

ask_and_run() {
  local prompt="$1"
  shift
  local yn
  read -r -p "$prompt (Y/N): " yn
  if [[ "$yn" =~ ^[Yy]$ ]]; then
    printf "Running:"
    printf " %q" "$@"
    printf "\n"
    "$@"
  else
    printf "Skipped:"
    printf " %q" "$@"
    printf "\n"
  fi
}

ask_and_run "Run nixos-rebuild for local system?" \
  sudo nixos-rebuild switch --flake path:.#

ask_and_run "Run nixos-rebuild for hetzner?" \
  nixos-rebuild switch --flake path:.#hetzner --target-host root@server

ask_and_run "Run nixos-rebuild for laptop?" \
  nixos-rebuild switch --flake path:.#laptop --target-host root@laptop

ask_and_run "Run nixos-rebuild for localserver?" \
  nixos-rebuild switch --flake path:.#localserver --target-host root@localserver

ask_and_run "Run nixos-rebuild for thinkcentre?" \
  nixos-rebuild switch --flake path:.#thinkcentre --target-host root@thinkcentre

ask_and_run "Build standalone Home Manager config?" \
  nix build path:.#homeConfigurations.hill.activationPackage --no-link --print-build-logs

ask_and_run "Build WSL tarball?" \
  sudo nix run path:.#nixosConfigurations.wsl.config.system.build.tarballBuilder
