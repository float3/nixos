{
  config,
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    kodi
    i3lock-fancy-rapid
  ];
}
