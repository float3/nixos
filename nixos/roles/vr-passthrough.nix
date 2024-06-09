# https://astrid.tech/2022/09/22/0/nixos-gpu-vfio/
let
  # RTX 2080 Ti
  gpuIDs = [
    "10de:1e87" # Graphics
    "10de:10f8" # Audio
  ];
in
  {
    pkgs,
    lib,
    config,
    ...
  }: {
    options.vfio.enable = with lib;
      mkEnableOption "Configure the machine for VFIO";

    config = let
      cfg = config.vfio;
    in {
      boot = {
        initrd.kernelModules = [
          "vfio_pci"
          "vfio"
          "vfio_iommu_type1"
          "vfio_virqfd"

          "nvidia"
          "nvidia_modeset"
          "nvidia_uvm"
          "nvidia_drm"
        ];

        kernelParams =
          [
            # enable IOMMU
            "amd_iommu=on"
          ]
          ++ lib.optional cfg.enable
          # isolate the GPU
          ("vfio-pci.ids=" + lib.concatStringsSep "," gpuIDs);
      };

      virtualisation.spiceUSBRedirection.enable = true;
    };
  }
