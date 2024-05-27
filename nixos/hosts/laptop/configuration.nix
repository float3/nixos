{
  config,
  pkgs,
  paths,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    "${paths.modules}/shared.nix"
    "${paths.modules}/local.nix"
    "${paths.modules}/devpackages.nix"
    "${paths.vendor}/amd.nix"
  ];

  environment = {
    systemPackages = with pkgs; [
    ];
  };

  boot.initrd.luks.devices."luks-6860d7e4-143a-49fc-bfbf-6374c49aed68".device = "/dev/disk/by-uuid/6860d7e4-143a-49fc-bfbf-6374c49aed68";

  # boot = {
  #   initrd = {
  #     secrets = {
  #       "/crypto_keyfile.bin" = null;
  #     };

  #     luks.devices."luks-a3e026a9-2863-4252-b3eb-db6c6edcfbb7".device = "/dev/disk/by-uuid/a3e026a9-2863-4252-b3eb-db6c6edcfbb7";
  #     luks.devices."luks-a3e026a9-2863-4252-b3eb-db6c6edcfbb7".keyFile = "/crypto_keyfile.bin";
  #   };
  # };

  system.stateVersion = "23.11";
}
