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
      enable = true;
      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          dmenu #application launcher most people use
          i3status # gives you the default i3 status bar
          i3lock #default i3 screen locker
          i3blocks #if you are planning on using i3blocks over i3status
        ];
      };
    };
  };

  environment.pathsToLink = ["/libexec"];

  environment.systemPackages = with pkgs; [
    picom
    kodi
    i3lock-fancy-rapid
    arandr
    # wineWow64Packages.staging
    wineWowPackages.staging
  ];
}
