{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.float3.kiosk;
in {
  options.float3.kiosk = {
    enable = lib.mkEnableOption "Chromium kiosk session";

    user = lib.mkOption {
      type = lib.types.str;
      default = "kiosk";
      description = "User account that owns the kiosk session.";
    };

    url = lib.mkOption {
      type = lib.types.str;
      default = "https://traeumerei.dev";
      description = "URL opened by Chromium in kiosk mode.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user} = {
      isNormalUser = true;
      description = "Kiosk";
      extraGroups = [
        "audio"
        "networkmanager"
        "video"
      ];
    };

    services = {
      displayManager = {
        autoLogin = {
          enable = true;
          user = cfg.user;
        };
        defaultSession = "none+kiosk";
      };

      xserver = {
        enable = true;
        displayManager.lightdm.enable = true;
        windowManager.session = [
          {
            name = "kiosk";
            start = ''
              ${pkgs.xset}/bin/xset -dpms
              ${pkgs.xset}/bin/xset s off
              ${pkgs.xsetroot}/bin/xsetroot -cursor_name left_ptr
              exec ${pkgs.chromium}/bin/chromium \
                --kiosk \
                --no-first-run \
                --disable-infobars \
                --disable-session-crashed-bubble \
                --ozone-platform=x11 \
                ${lib.escapeShellArg cfg.url}
            '';
          }
        ];
        xkb.layout = "us,de";
        xkb.options = "grp:win_space_toggle";
      };

      libinput.enable = true;
      pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };
    };

    security.rtkit.enable = true;

    hardware = {
      graphics.enable = true;
      bluetooth.enable = lib.mkDefault false;
    };

    environment = {
      variables.BROWSER = "chromium";
      systemPackages = with pkgs; [
        chromium
        xset
        xsetroot
      ];
    };
  };
}
