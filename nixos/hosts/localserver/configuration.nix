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
