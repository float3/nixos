{
  config,
  pkgs,
  lib,
  inputs,
  paths,
  ...
}: let
  jovianNixos = inputs."jovian-nixos" or null;
  hasJovian = jovianNixos != null;
in
  {
    imports =
      [
        ./hardware-configuration.nix
        "${paths.roles}/base.nix"
        "${paths.modules}/local.nix"
        "${paths.modules}/localpackages.nix"
        "${paths.roles}/gaming.nix"
      ]
      ++ lib.optional hasJovian (jovianNixos + "/modules");

    services.displayManager = lib.mkIf hasJovian {
      defaultSession = "gamescope-wayland";
    };

    systemd.services.gamescope-switcher = lib.mkIf hasJovian {
      wantedBy = ["graphical.target"];
      serviceConfig = {
        User = 1000;
        PAMName = "login";
        WorkingDirectory = "~";

        TTYPath = "/dev/tty7";
        TTYReset = "yes";
        TTYVHangup = "yes";
        TTYVTDisallocate = "yes";

        StandardInput = "tty-fail";
        StandardOutput = "journal";
        StandardError = "journal";

        UtmpIdentifier = "tty7";
        UtmpMode = "user";

        Restart = "always";
      };

      script = ''
        set-session () {
          mkdir -p ~/.local/state
          >~/.local/state/steamos-session-select echo "$1"
        }
        consume-session () {
          if [[ -e ~/.local/state/steamos-session-select ]]; then
            cat ~/.local/state/steamos-session-select
            rm ~/.local/state/steamos-session-select
          else
            echo "gamescope"
          fi
        }
        while :; do
          session=$(consume-session)
          case "$session" in
            plasma)
              dbus-run-session -- gnome-shell --display-server --wayland
              ;;
            gamescope)
              steam-session
              ;;
          esac
        done
      '';
    };

    environment = {
      systemPackages = lib.optionals hasJovian (with pkgs; [
        jupiter-dock-updater-bin
        steamdeck-firmware
      ]);
    };

    system.stateVersion = "24.11";
  }
  // lib.optionalAttrs hasJovian {
    jovian = {
      steam.enable = true;
      decky-loader.enable = true;
      devices.streamdeck.enable = true;
    };
  }
