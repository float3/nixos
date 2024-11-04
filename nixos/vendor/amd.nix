{
  config,
  pkgs,
  lib,
  paths,
  ...
}: {
  imports = ["${paths.modules}/wayland.nix"];
  boot.initrd.kernelModules = ["amdgpu"];

  hardware.graphics = {
    extraPackages = with pkgs; [
      amdvlk
    ];
    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
    ];
  };
  services.xserver.videoDrivers = ["amdgpu"];

  environment.systemPackages = with pkgs; [
      nvtopPackages.amd
  ];
}
