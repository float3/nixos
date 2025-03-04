{
  pkgs,
  inputs,
  ...
}: let
  sm64exa =
    import (pkgs.fetchFromGitHub {
      owner = "N00byKing";
      repo = "sm64ex";
      rev = "4cf8e320e0d905eb9ae6f514cb9d904ba22516cf";
      sha256 = "sha256-32lKUNiMXGL6z4nQX+u8SqFBheKMZ09+HfuzL2Ps1eM=";
    }) {
      inherit pkgs;
    };
in {
  nixpkgs.overlays = [
    # inputs.prismlauncher.overlays.default
    inputs.ow-mod-man.overlays.default
  ];

  # boot.initrd.kernelModules = ["usbhid" "joydev" "xpad"];
  environment.systemPackages = with pkgs; [
    # https://github.com/TASEmulators/BizHawk?tab=readme-ov-file#nixnixos
    archipelago
    bizhawk
    owmods-cli
    owmods-gui
    prismlauncher
    shadps4
    sm64ex
    widelands
  ];
}
