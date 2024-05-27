{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [../wayland.nix];
  boot.initrd.kernelModules = ["amdgpu"];

  hardware.opengl = {
    extraPackages = with pkgs; [
      amdvlk
    ];
    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
    ];
  };
  services.xserver.videoDrivers = ["amdgpu"];
}
