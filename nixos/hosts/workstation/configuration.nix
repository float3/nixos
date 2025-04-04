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
      name = "wayland";
      config = {
        imports = ["${paths.modules}/wayland.nix"];
        disabledModules = ["${paths.modules}/x11.nix"];
      };
    }
    {
      name = "x11";
      config = {
        imports = ["${paths.modules}/x11.nix"];
        disabledModules = ["${paths.modules}/wayland.nix"];
      };
    }
  ];

  nvidiaVariants = [
    {
      name = "nvidia-closed";
      config = {
        hardware.nvidia = {
          open = lib.mkForce false;
        };
      };
    }
    {
      name = "nvidia-open";
      config = {
        hardware.nvidia = {
          open = lib.mkForce true;
        };
      };
    }
  ];

  nvidiaPackage = [
    {
      name = "nvidia-stable";
      config = {
        hardware.nvidia.package = lib.mkForce config.boot.kernelPackages.nvidiaPackages.stable;
      };
    }
    {
      name = "nvidia-beta";
      config = {
        hardware.nvidia.package = lib.mkForce config.boot.kernelPackages.nvidiaPackages.beta;
      };
    }
    #   {
    #      name = "nvidia-latest";
    # config = {
    #    hardware.nvidia.package = lib.mkForce config.boot.kernelPackages.nvidiaPackages.latest;
    #   };
    #  }
    #   {
    #      name = "nvidia-production";
    #      config = {
    #        hardware.nvidia.package = lib.mkForce config.boot.kernelPackages.nvidiaPackages.production;
    #      };
    #    }
    # {
    #   name = "nvidia-535";
    #   config = {
    #     hardware.nvidia.package = let
    #       rcu_patch = pkgs.fetchpatch {
    #         url = "https://github.com/gentoo/gentoo/raw/c64caf53/x11-drivers/nvidia-drivers/files/nvidia-drivers-470.223.02-gpl-pfn_valid.patch";
    #         hash = "sha256-eZiQQp2S/asE7MfGvfe6dA/kdCvek9SYa/FFGp24dVg=";
    #       };
    #     in
    #       config.boot.kernelPackages.nvidiaPackages.mkDriver {
    #         version = "535.154.05";
    #         sha256_64bit = "sha256-fpUGXKprgt6SYRDxSCemGXLrEsIA6GOinp+0eGbqqJg=";
    #         sha256_aarch64 = "sha256-G0/GiObf/BZMkzzET8HQjdIcvCSqB1uhsinro2HLK9k=";
    #         openSha256 = "sha256-wvRdHguGLxS0mR06P5Qi++pDJBCF8pJ8hr4T8O6TJIo=";
    #         settingsSha256 = "sha256-9wqoDEWY4I7weWW05F4igj1Gj9wjHsREFMztfEmqm10=";
    #         persistencedSha256 = "sha256-d0Q3Lk80JqkS1B54Mahu2yY/WocOqFFbZVBh+ToGhaE=";

    #         patches = [rcu_patch];
    #       };
    #   };
    # }
    # {
    #   name = "nvidia-550";
    #   config = {
    #     hardware.nvidia.package = let
    #       rcu_patch = pkgs.fetchpatch {
    #         url = "https://github.com/gentoo/gentoo/raw/c64caf53/x11-drivers/nvidia-drivers/files/nvidia-drivers-470.223.02-gpl-pfn_valid.patch";
    #         hash = "sha256-eZiQQp2S/asE7MfGvfe6dA/kdCvek9SYa/FFGp24dVg=";
    #       };
    #     in
    #       config.boot.kernelPackages.nvidiaPackages.mkDriver {
    #         version = "550.40.07";
    #         sha256_64bit = "sha256-KYk2xye37v7ZW7h+uNJM/u8fNf7KyGTZjiaU03dJpK0=";
    #         sha256_aarch64 = "sha256-AV7KgRXYaQGBFl7zuRcfnTGr8rS5n13nGUIe3mJTXb4=";
    #         openSha256 = "sha256-mRUTEWVsbjq+psVe+kAT6MjyZuLkG2yRDxCMvDJRL1I=";
    #         settingsSha256 = "sha256-c30AQa4g4a1EHmaEu1yc05oqY01y+IusbBuq+P6rMCs=";
    #         persistencedSha256 = "sha256-11tLSY8uUIl4X/roNnxf5yS2PQvHvoNjnd2CB67e870=";

    #         patches = [rcu_patch];
    #       };
    #   };
    # }
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
    "${paths.modules}/wayland.nix"
    "${paths.roles}/dev.nix"
    "${paths.roles}/desktop.nix"
    "${paths.roles}/gaming.nix"
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

  #boot = {
  #  initrd = {
  #    secrets = {
  #      "/crypto_keyfile.bin" = null;
  #    };
  #
  #    luks.devices."luks-a3e026a9-2863-4252-b3eb-db6c6edcfbb7".device = "/dev/disk/by-uuid/a3e026a9-2863-4252-b3eb-db6c6edcfbb7";
  #    luks.devices."luks-a3e026a9-2863-4252-b3eb-db6c6edcfbb7".keyFile = "/crypto_keyfile.bin";
  #  };
  #};

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

  system.stateVersion = "24.11";
}
