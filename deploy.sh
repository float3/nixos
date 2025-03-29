#!/usr/bin/env bash

hostname=$(hostname)

# Check if hostname matches any of the specified names
if [[ \"$hostname\" =~ ^(workstation|laptop|steamdeck)$ ]]; then
    nix-store --add-fixed sha256 baserom.us.z64
fi

sudo nixos-rebuild switch --flake .#workstation
nixos-rebuild switch --flake .#hetzner --target-host root@server
nixos-rebuild switch --flake .#laptop --target-host root@laptop
nixos-rebuild switch --flake .#localserver --target-host root@localserver
sudo nix run .#nixosConfigurations.wsl.config.system.build.tarballBuilder
wait
