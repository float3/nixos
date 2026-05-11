{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.float3.wayland;
in {
  options.float3.wayland.extras.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable heavier Wayland extras such as Waydroid and media/game compatibility packages.";
  };

  config = {
    environment = {
      variables = {
        #WAYLAND_DISPLAY = "wayland-0"; # check this
        GTK_IM_MODULE = "wayland";
        NIXOS_OZONE_WL = "1";
        MOZ_ENABLE_WAYLAND = "1";
        QT_IM_MODULE = "fcitx5";
      };
      systemPackages =
        (with pkgs; [
          mako
          swaylock
          grimblast
          xwayland
          wlr-layout-ui
        ])
        ++ lib.optionals cfg.extras.enable (with pkgs; [
          wineWow64Packages.waylandFull
          kodi-wayland
        ]);
    };

    programs = {
      sway = {
        enable = true;
        xwayland.enable = true;
      };
      hyprland = {
        enable = true;
        xwayland.enable = true;
      };
      waybar.enable = true;
      xwayland.enable = true;
    };

    i18n.inputMethod.fcitx5.waylandFrontend = true;

    services = {
      displayManager = {
        defaultSession = "hyprland";
        sddm = {
          enable = lib.mkDefault true;
          wayland.enable = true;
        };
      };

      xserver = {
        windowManager.hypr.enable = true;
      };
    };

    virtualisation.waydroid.enable = lib.mkIf cfg.extras.enable true;
  };
}
