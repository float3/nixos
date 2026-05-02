{
  config,
  pkgs,
  lib,
  paths,
  ...
}: {
  imports = ["${paths.modules}/wayland.nix"];
  boot.initrd.kernelModules = ["amdgpu"];

  hardware.graphics.enable = true;
  services.xserver.videoDrivers = ["amdgpu"];

  environment.systemPackages = with pkgs; [
    nvtopPackages.amd
  ];
}
