{
  pkgs,
  inputs,
  ...
}: {
  environment = {
    nixpkgs.overlay = [inputs.prismlauncher.overlays.default];
    systemPackages = with pkgs; [
      prismlauncher
    ];
  };
}
