{
  username,
  config,
  pkgs,
  inputs,
  paths,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    "${paths.roles}/base.nix"
    "${paths.modules}/local.nix"
    "${paths.vendor}/nvidia.nix"
    "${paths.roles}/vr-passthrough.nix"
    "${paths.modules}/wayland.nix"
    "${paths.roles}/dev.nix"
    "${paths.roles}/desktop.nix"
  ];

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

  specialisation."VFIO".configuration = {
    system.nixos.tags = ["with-vfio"];
    vfio.enable = true;
  };

  system.stateVersion = "22.11";
}
