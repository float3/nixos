{
  username,
  config,
  pkgs,
  inputs,
  paths,
  lib,
  ...
}: let
  wmVariants = [
    {
      name = "x11";
      config = {
        imports = ["${paths.modules}/x11.nix"];
        disabledModules = ["${paths.modules}/wayland.nix"];
      };
    }
    {
      name = "wayland";
      config = {
        imports = ["${paths.modules}/wayland.nix"];
        disabledModules = ["${paths.modules}/x11.nix"];
      };
    }
  ];

  nvidiaVariants = [
    {
      name = "nvidia-closed";
      config = {
        hardware.nvidia = {
          open = false;
        };
      };
    }
    {
      name = "nvidia-open";
      config = {
        hardware.nvidia = {
          open = true;
        };
      };
    }
  ];

  nvidiaPackage = [
    {
      name = "nvidia-stable";
      config = {
        hardware.nvidia = {
          package = config.boot.kernelPackages.nvidiaPackages.stable;
        };
      };
    }
    {
      name = "nvidia-beta";
      config = {
        hardware.nvidia = {
          package = config.boot.kernelPackages.nvidiaPackages.beta;
        };
      };
    }
  ];

  combinations = lib.cartesianProduct {
    x11 = wmVariants;
    nvidia = nvidiaVariants;
    nvidiaPackage = nvidiaPackage;
  };

  specialisations = builtins.listToAttrs (
    builtins.map (
      combo: let
        wmTag = combo.x11.name;
        nvTag = combo.nvidia.name;
        npTag = combo.nvidiaPackage.name;
        finalTags = [wmTag nvTag npTag];
        finalName = lib.concatStringsSep "+" finalTags;
        mergedConfig = combo.x11.config // combo.nvidia.config // combo.nvidiaPackage.config;
      in
        lib.nameValuePair finalName {configuration = mergedConfig;}
    )
    combinations
  );
in {
  imports = [
    ./hardware-configuration.nix
    "${paths.roles}/base.nix"
    "${paths.modules}/local.nix"
    "${paths.vendor}/nvidia.nix"
    # "${paths.roles}/vr-passthrough.nix"
    "${paths.modules}/x11.nix"
    "${paths.roles}/dev.nix"
    "${paths.roles}/desktop.nix"
  ];

  specialisation = specialisations;

  # specialisation."x11".configuration = {...}: {
  #   imports = [
  #     "${paths.modules}/x11.nix"
  #   ];

  #   disabledModules = [
  #     "${paths.modules}/wayland.nix"
  #   ];
  # };

  boot = {
    initrd = {
      secrets = {
        "/crypto_keyfile.bin" = null;
      };

      luks.devices."luks-a3e026a9-2863-4252-b3eb-db6c6edcfbb7".device = "/dev/disk/by-uuid/a3e026a9-2863-4252-b3eb-db6c6edcfbb7";
      luks.devices."luks-a3e026a9-2863-4252-b3eb-db6c6edcfbb7".keyFile = "/crypto_keyfile.bin";
    };
  };

  environment = {
    systemPackages = with pkgs; [
    ];
  };

  users.users.${username}.extraGroups = ["libvirtd"];

  # dconf.settings = {
  #   "org/virt-manager/virt-manager/connections" = {
  #     autoconnect = ["qemu:///system"];
  #     uris = ["qemu:///system"];
  #   };
  # };

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # specialisation."VFIO".configuration = {
  #   system.nixos.tags = ["with-vfio"];
  #   vfio.enable = true;
  # };

  system.stateVersion = "22.11";
}
