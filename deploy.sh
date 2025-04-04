#!/usr/bin/env bash

hostname=$(hostname)

# Check if hostname matches any of the specified names
if [[ \"$hostname\" =~ ^(workstation|laptop|steamdeck)$ ]]; then
    nix-store --add-fixed sha256 baserom.us.z64
fi

ask_and_run() {
  local prompt="$1"
  local cmd="$2"
  read -p "$prompt (Y/N): " yn
  if [[ "$yn" =~ ^[Yy]$ ]]; then
    echo "Running: $cmd"
    eval "$cmd"
  else
    echo "Skipped: $cmd"
  fi
}

ask_and_run "Run nixos-rebuild for local system?" \
  "sudo nixos-rebuild switch --flake .#"

ask_and_run "Run nixos-rebuild for hetzner?" \
  "nixos-rebuild switch --flake .#hetzner --target-host root@server"

ask_and_run "Run nixos-rebuild for laptop?" \
  "nixos-rebuild switch --flake .#laptop --target-host root@laptop"

ask_and_run "Run nixos-rebuild for localserver?" \
  "nixos-rebuild switch --flake .#localserver --target-host root@localserver"

ask_and_run "Build WSL tarball?" \
  "sudo nix run .#nixosConfigurations.wsl.config.system.build.tarballBuilder"

