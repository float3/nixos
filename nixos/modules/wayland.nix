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
      wineWowPackages.waylandFull
      # wineWow64Packages.waylandFull
      kodi-wayland
      swaylock
      grimblast
      wlr-layout-ui
    ];
  };

  programs = {
    sway.enable = true;
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    waybar.enable = true;
  };

  i18n.inputMethod.fcitx5.waylandFrontend = true;

  services = {
    displayManager = {
      defaultSession = "hyprland";
      sddm.wayland.enable = lib.mkDefault false;
    };

    xserver = {
      windowManager.hypr.enable = true;
    };
  };
  virtualisation.waydroid.enable = true;
}
