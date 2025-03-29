#!/usr/bin/env bash

hostname=$(hostname)

# Check if hostname matches any of the specified names
if [[ \"$hostname\" =~ ^(workstation|laptop|steamdeck)$ ]]; then
    nix-store --add-fixed sha256 baserom.us.z64
fi

# Perform local rebuild with hostname in background
sudo nixos-rebuild switch --upgrade --flake .#\"$hostname\"

# Perform remote rebuild for hetzner server simultaneously
nixos-rebuild switch --upgrade --flake .#hetzner --target-host root@server

# Wait for both rebuilds to complete
wait
