{
  pkgs,
  inputs,
  ...
}: {
  nixpkgs.overlay = [inputs.prismlauncher.overlays.default];
  environment = {
    systemPackages = with pkgs; [
      prismlauncher
    ];
  };

  programs.envision = {
    enable = true;
    openFirewall = true;
  };
}
