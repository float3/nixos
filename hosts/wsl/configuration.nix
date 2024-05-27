{
  config,
  pkgs,
  lib,
  username,
  nixos-wsl,
  ...
}: {
  imports = [
    ../../desktop.nix
    nixos-wsl.nixosModules.wsl
  ];

  system.stateVersion = "23.05";

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    defaultUser = ${username};
    startMenuLaunchers = true;
    docker-native.enable = true;
  };

  environment.systemPackages = with pkgs; [
    busybox
  ];

  home-manager.users.hill.programs.vscode.enable = lib.mkForce false;
  home-manager.users.hill.programs.tmux.extraConfig = ''
    # https://github.com/microsoft/WSL/issues/5931#issuecomment-1296783606
    set -sg escape-time 50
  '';
  home-manager.users.hill.programs.zsh.envExtra = ''
    # WSL extra config
    clear
  '';
}
