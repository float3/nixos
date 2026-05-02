{
  pkgs,
  lib,
  paths,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    "${paths.roles}/base.nix"
    "${paths.roles}/kiosk.nix"
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  float3.kiosk = {
    enable = true;
    url = "https://traeumerei.dev";
  };

  system.stateVersion = "24.11";
}
