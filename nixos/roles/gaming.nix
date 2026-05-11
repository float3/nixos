{
  pkgs,
  inputs,
  ...
}: let
  sm64exa =
    import (pkgs.fetchFromGitHub {
      owner = "N00byKing";
      repo = "sm64ex";
      rev = "a4092cb1e7f0f09c46228833f36d6aeffddb1731";
      sha256 = "sha256-Wf/qnwF0tfI6X7kBdwlq1qI+SStPoV1jyPxY9n9pcR8=";
    }) {
      inherit pkgs;
    };
  # bizhawk =
  #   import (pkgs.fetchFromGitHub {
  #     owner = "TASEmulators";
  #     repo = "BizHawk";
  #     rev = "8ba8bd61b42c5cbabb65053e485944fd21546072";
  #     sha256 = "sha256-4UJt8Z7bIbV0HAlIcBUlip75qGjaMFtHMGx4NMYgCEM=";
  #   }) {
  #     inherit pkgs;
  #     system = builtins.currentSystem;
  #   };
in {
  nixpkgs.overlays = [
    # inputs.prismlauncher.overlays.default
    inputs.ow-mod-man.overlays.default
  ];

  # boot.initrd.kernelModules = ["usbhid" "joydev" "xpad"];
  environment.systemPackages = with pkgs; [
    # https://github.com/TASEmulators/BizHawk?tab=readme-ov-file#nixnixos
    archipelago
    # bizhawk.emuhawk-latest-bin
    # owmods-cli
    # owmods-gui
    prismlauncher
    shadps4
    rpcs3
    sm64ex
    winePackages.fonts
    protonup-qt
    protonplus
    winetricks
    # widelands
    # nexusmods-app
    # (nexusmods-app.override
    #   {
    #     _7zz = pkgs._7zz-rar;
    #   })
  ];

  programs = {
    gamemode.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extest.enable = true;
      protontricks = {
        enable = true;
      };
      package = pkgs.steam.override {
        extraEnv = {
          MANGOHUD = true;
          OBS_VKCAPTURE = true;
          RADV_TEX_ANISO = 16;
        };
        extraLibraries = p:
          with p; [
            atk
          ];
      };
    };
  };
}
