{
  pkgs,
  inputs,
  ...
}: let
  firefoxSettings = {
    "browser.compactmode.show" = true;
    "browser.theme.content-theme" = 2;
    "extensions.activeThemeID" = "{e410fec2-1cbd-4098-9944-e21e708418af}";
    "gfx.webrender.all" = true;
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
  };

  userChrome = ''
    @namespace url("http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul");

    *,
    .rounded-left,
    .rounded-left-1,
    .rounded-left-2,
    .rounded-left-3,
    .rounded-right,
    .rounded-right-1,
    .rounded-right-2,
    .rounded-right-3 {
      border-radius: 0 !important;
    }
  '';
in {
  home.packages =
    (with pkgs; [
      chromium
      keepassxc
      librewolf
      obsidian
      qbittorrent
      telegram-desktop
      thunderbird
      vesktop
      yt-dlp
    ])
    ++ (with inputs.float3-flakes.packages.${pkgs.system}; [
      # These carry their configuration in the Nix store, replacing both the
      # plain nixpkgs builds and the matching files in float3/.config.
      # hyprland execs waybar, eww and rofi by bare name, so these wrappers
      # are what actually run.
      alacritty
      eww
      mpv
      polybar
      rofi
      waybar
    ]);

  programs = {
    firefox = {
      enable = true;
      configPath = ".mozilla/firefox";
      package = pkgs.firefox;
      profiles.home-manager = {
        id = 0;
        isDefault = true;
        name = "home-manager";
        settings = firefoxSettings;
        userChrome = userChrome;
        search = {
          force = true;
          default = "searx";
          privateDefault = "searx";
          engines.searx = {
            urls = [
              {
                template = "https://searx.envs.net/search";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            definedAliases = ["@s"];
            icon = "https://searx.envs.net/favicon.ico";
            updateInterval = 24 * 60 * 60 * 1000;
          };
        };
      };
    };
  };

  services.syncthing.enable = true;
}
