{
  config,
  pkgs,
  lib,
  jovian-nixos,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    (jovian-nixos + "/modules")
    ../../modules/shared.nix
    ../../modules/local.nix
  ];

  jovian = {
    steam.enable = true;
    devices.streamdeck.enable = true;
  };

  services.displayManager = {
    defaultSession = "gamescope-wayland";
  };

  systemd.services.gamescope-switcher = {
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

  sound.enable = true;

  environment = {
    systemPackages = with pkgs; [
      jupiter-dock-updater-bin
      steamdeck-firmware
    ];
  };
}
