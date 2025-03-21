{
  config,
  pkgs,
  lib,
  ...
}: {
  boot.extraModulePackages = [config.boot.kernelPackages.nvidia_x11];

  nixpkgs.config = lib.mkIf (lib.elem "nvidia" config.boot.initrd.kernelModules) {
    allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "#nvidia-x11"
      ];
  };
  services = {
    displayManager.defaultSession = "none+i3";
    xserver = {
      windowManager.i3.enable = true;
      extraConfig = "LogVerbose 6";
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
