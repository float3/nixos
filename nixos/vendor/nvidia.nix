{
  config,
  pkgs,
  lib,
  paths,
  ...
}: {
  boot = {
    kernelParams = ["nvidia.NVreg_PreserveVideoMemoryAllocations=1" "nvidia-drm.modeset=1"];
    initrd.kernelModules = ["nvidia"];
  };

  hardware = {
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
      open = lib.mkDefault true;
      nvidiaSettings = true;
      package = lib.mkDefault config.boot.kernelPackages.nvidiaPackages.beta; # change to beta
    };
  };

  virtualisation.docker.enableNvidia =
    if config.virtualisation.docker.enable
    then true
    else false;

  nixpkgs.config = {
    allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "#nvidia-settings"
        "#nvidia-persistenced"
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
