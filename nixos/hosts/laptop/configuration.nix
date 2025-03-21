{
  config,
  pkgs,
  paths,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    "${paths.roles}/base.nix"
    "${paths.modules}/local.nix"
    "${paths.vendor}/amd.nix"
    "${paths.modules}/wayland.nix"
    "${paths.roles}/dev.nix"
  ];

  specialisation."x11".configuration = {...}: {
    imports = [
      "${paths.modules}/x11.nix"
    ];

    disabledModules = [
      "${paths.modules}/wayland.nix"
    ];

    services.displayManager.sddm.wayland.enable = lib.mkForce false;
  };

  environment = {
    systemPackages = with pkgs; [
    ];
  };

  boot.initrd.luks.devices."luks-6860d7e4-143a-49fc-bfbf-6374c49aed68".device = "/dev/disk/by-uuid/6860d7e4-143a-49fc-bfbf-6374c49aed68";

  services = {
    # thermald.enable = false;
    # power-profiles-daemon.enable = true;
    # auto-cpufreq = {
    #   enable = false;
    #   settings = {
    #     battery = {
    #       governor = "powersave";
    #       turbo = "never";
    #     };
    #     charger = {
    #       governor = "performance";
    #       turbo = "auto";
    #     };
    #   };
    # };
  };

  # powerManagement.powertop.enable = true;

  # boot = {
  #   initrd = {
  #     secrets = {
  #       "/crypto_keyfile.bin" = null;
  #     };

  #     luks.devices."luks-a3e026a9-2863-4252-b3eb-db6c6edcfbb7".device = "/dev/disk/by-uuid/a3e026a9-2863-4252-b3eb-db6c6edcfbb7";
  #     luks.devices."luks-a3e026a9-2863-4252-b3eb-db6c6edcfbb7".keyFile = "/crypto_keyfile.bin";
  #   };
  # };

  # overrides
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.xserver.displayManager.lightdm.enable = false;

  system.stateVersion = "23.11";
}
