{
  config,
  pkgs,
  lib,
  ...
}: {
  boot.extraModulePackages = [config.boot.kernelPackages.nvidia_x11];

  nixpkgs.config = {
    allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "#nvidia-x11"
      ];
  };
  services = {
    displayManager.defaultSession = "none+i3";
    xserver = {
      windowManager.i3.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    picom # xserver
    kodi
    i3lock-fancy-rapid
    arandr
  ];
}
