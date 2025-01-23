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
      sha256 = "sha256-KXe69svPIIFaXgT9t+02pwdQ6WWqdqgUdtaE2S4/YxA=";
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
    prismlauncher
    # archipelago
    # bizhawk
    # sm64exa
    # https://github.com/TASEmulators/BizHawk?tab=readme-ov-file#nixnixos
    # BeatSaberModManager
    owmods-gui
    owmods-cli
  ];

  programs.envision = {
    enable = true;
    openFirewall = true;
  };
}
