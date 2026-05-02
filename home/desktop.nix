{pkgs, ...}: let
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
  home.packages = with pkgs; [
    alacritty
    chromium
    keepassxc
    librewolf
    mpv
    obsidian
    qbittorrent
    telegram-desktop
    thunderbird
    vesktop
    yt-dlp
  ];

  programs = {
    alacritty = {
      enable = true;
      settings = {
        env.TERM = "xterm-256color";
        window.opacity = 0.75;
        font.normal = {
          family = "Monaspace Neon";
          style = "Regular";
        };
        selection.save_to_clipboard = true;
      };
    };

    firefox = {
      enable = true;
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
