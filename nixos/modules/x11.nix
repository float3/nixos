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

  environment.systemPackages = with pkgs; [
    kodi
    i3lock-fancy-rapid
    arandr
  ];
}
