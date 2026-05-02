{
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "usb_storage"
      "sd_mod"
    ];
    kernelModules = ["kvm-intel"];
  };

  fileSystems = {
    "/" = {
      device = lib.mkDefault "/dev/disk/by-label/nixos";
      fsType = lib.mkDefault "ext4";
    };

    "/boot" = {
      device = lib.mkDefault "/dev/disk/by-label/BOOT";
      fsType = lib.mkDefault "vfat";
    };
  };

  swapDevices = [];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
}
