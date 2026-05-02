{
  config,
  pkgs,
  lib,
  ...
}: {
  environment = {
    variables = {
      #WAYLAND_DISPLAY = "wayland-0"; # check this
      GTK_IM_MODULE = "wayland";
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      QT_IM_MODULE = "fcitx5";
    };
    systemPackages = with pkgs; [
      mako
      wineWow64Packages.waylandFull
      kodi-wayland
      swaylock
      grimblast
      xwayland
      wlr-layout-ui
    ];
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
      sddm.wayland.enable = true;
    };

    xserver = {
      windowManager.hypr.enable = true;
    };
  };
  virtualisation.waydroid.enable = true;
}
