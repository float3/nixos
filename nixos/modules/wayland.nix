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
      # wineWowPackages.waylandFull
      nvtopPackages.amd
      swaylock
      grimblast
    ];
  };

  programs = {
    sway.enable = false;
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    waybar.enable = true;
  };

  i18n.inputMethod.fcitx5.waylandFrontend = true;

  services = {
    displayManager = {
      sddm.wayland.enable = true;
    };
    xserver = {
      windowManager = {
        hypr.enable = true;
      };
    };
  };
}
