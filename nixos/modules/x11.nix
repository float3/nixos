{
  config,
  pkgs,
  lib,
  ...
}: let
  hasNvidia = lib.elem "nvidia" config.boot.initrd.kernelModules;
in {
  boot.extraModulePackages = lib.mkIf hasNvidia [config.boot.kernelPackages.nvidia_x11];

  nixpkgs.config.allowUnfreePredicate = lib.mkIf hasNvidia (pkg:
    builtins.elem (lib.getName pkg) [
      "nvidia-x11"
      "nvidia_x11"
    ]);

  services = {
    displayManager.defaultSession = "none+i3";
    xserver = {
      windowManager.i3.enable = true;
      # extraConfig = "LogVerbose 6";
    };
  };

  environment.systemPackages = with pkgs; [
    picom
    kodi
    i3lock-fancy-rapid
    arandr
    # wineWow64Packages.staging
    wineWowPackages.staging
  ];
}
