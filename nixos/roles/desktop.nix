{
  pkgs,
  inputs,
  ...
}: {
  nixpkgs.overlays = [
    inputs.prismlauncher.overlays.default
    inputs.ow-mod-man.overlays.default
  ];

  environment = {
    systemPackages = with pkgs; [
      prismlauncher
      meson
      BeatSaberModManager
      owmods-gui
      owmods-cli
    ];
  };

  programs.envision = {
    enable = true;
    openFirewall = true;
  };
}
