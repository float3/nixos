{
  config,
  pkgs,
  inputs,
  paths,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    "${paths.modulesPath}/shared.nix"
    "${paths.modulesPath}/local.nix"
    "${paths.modulesPath}/devpackages.nix"
    "${paths.vendorPath}/nvidia.nix"
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
      meson
      BeatSaberModManager
    ];
  };

  system.stateVersion = "22.11";
}
