{
  lib,
  paths,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    "${paths.roles}/base.nix"
    "${paths.roles}/dev.nix"
    "${paths.modules}/local.nix"
    "${paths.modules}/localpackages.nix"
    "${paths.modules}/wayland.nix"
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd.luks.devices."luks-28f911f1-d35f-452f-89fa-b705650f5227".device = "/dev/disk/by-uuid/28f911f1-d35f-452f-89fa-b705650f5227";
  };

  networking = {
    hostName = lib.mkForce "macbook";
  };

  float3.wayland.extras.enable = false;

  system.stateVersion = "25.11";
}
