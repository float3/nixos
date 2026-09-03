let
  domain = "traeumerei.dev";
in
  {
    username,
    paths,
    modulesPath,
    config,
    lib,
    inputs,
    pkgs,
    float3-keys,
    akaimage-keys,
    e00e-keys,
    pema99-keys,
    nyrox-keys,
    stephen-keys,
    ...
  }: {
    imports = [
      ./hardware-configuration.nix
      "${paths.roles}/base.nix"
      "${paths.modules}/builder.nix"
      "${paths.modules}/local.nix"
      "${paths.modules}/localpackages.nix"
    ];

    environment = {
      systemPackages = with pkgs; [
        ffmpeg
        nodejs_22
      ];
    };

    programs = {};

    system.stateVersion = "24.11";
  }
