{
  config,
  pkgs,
  lib,
  paths,
  ...
}: {
  imports = ["${paths.modules}/non-wayland.nix"];
  boot = {
    kernelParams = ["nvidia.NVreg_PreserveVideoMemoryAllocations=1"];
    extraModulePackages = [config.boot.kernelPackages.nvidia_x11];
    initrd.kernelModules = ["nvidia"];
  };

  hardware = {
    graphics.enable32Bit = true;
    nvidia = {
      modesetting.enable = true;
      powerManagement = {
        enable = false;
        finegrained = false;
      };
      forceFullCompositionPipeline = true;

      # Use the NVidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      # Support is limited to the Turing and later architectures. Full list of
      # supported GPUs is at:
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
      # Only available from driver 515.43.04+
      # Currently alpha-quality/buggy, so false is currently the recommended setting.
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable; # change to beta
    };
  };

  nixpkgs.config = {
    allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "#nvidia-x11"
      ];
  };

  environment = {
    systemPackages = with pkgs; [
      nvtopPackages.nvidia
    ];
  };

  services = {
    xserver = {
      videoDrivers = ["nvidia"];
    };
  };
}
