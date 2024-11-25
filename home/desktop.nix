{
  config,
  pkgs,
  home-manager,
  nur,
  myFlakes,
  ...
}: let
  system = pkgs.system;
  homeDir = config.home.homeDirectory;
  browser = "librewolf";
  firefox-settings = {
    # Settings in all Firefox derivatives
    "browser.compactmode.show" = true; # enable compact bar
    "browser.theme.content-theme" = 2; # don't use system theme
    "extensions.activeThemeID" = "{e410fec2-1cbd-4098-9944-e21e708418af}"; # Nord theme
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true; # userChrome.css
    # "network.proxy.no_proxies_on" = noproxies;
    # "network.proxy.socks" = socksProxy;
    # "network.proxy.socks_port" = socksPort;
    "gfx.webrender.all" = true;
  };
  librewolf-settings = {};

  userChrome = ''
    /* userChrome.css */
    @namespace url("http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul");

    /* Remove border-radius for various elements */
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
        border-top-left-radius: 0 !important;
        border-top-right-radius: 0 !important;
        border-bottom-right-radius: 0 !important;
        border-bottom-left-radius: 0 !important;
    }
  '';

  firefox-config = {
    enable = true;
    packages = pkgs.firefox.override {
      cfg = {
        # enableGnomeExtensions = true;
      };
    };

    profiles.home-manager = {
      search.force = true; # might be required
      bookmarks = [
        {
          # nixos folder
          name = "nixos";
          bookmarks = [
            {
              name = "nixos configuration options";
              url = "https://search.nixos.org/options?";
            }
            {
              name = "home-manager configuration options";
              url = "https://nix-community.github.io/home-manager/options.xhtml";
            }
            {
              name = "nix-darwin configuration options";
              url = "https://daiderd.com/nix-darwin/manual/index.html#sec-options";
            }
            {
              name = "nix packages";
              url = "https://search.nixos.org/packages";
            }
            {
              name = "nixos discourse";
              url = "https://discourse.nixos.org/";
            }
          ];
        }
      ];
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        darkreader
      ];
      policies.ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
      };
      isDefault = true;
      name = "home-manager";
      search = {
        engines = {
          "searx" = {
            urls = [{template = "https://searx.envs.net/search?q={searchTerms}";}];
            definedAliases = ["@s"];
            iconUpdateURL = "https://searx.envs.net/favicon.ico";
            updateInterval = 24 * 60 * 60 * 1000; # every day
          };
        };
        default = "searx";
        privateDefault = "searx";
      };
      userChrome = userChrome;
      settings = common-firefox-settings;
    };
  };

  librewolf-config =
    firefox-config
    // {
      packages = pkgs.librewolf;
      settings = firefox-settings // librewolf-settings;
    };

  vscodeSettingsDir =
    if pkgs.stdenv.isDarwin
    then "Library/Application Support/Code/User"
    else ".config/Code/User";

  myVscode = myFlakes.packages.${system}.vscode;
in {
  home.pacakges = [
    myVscode
  ];

  programs.firefox = firefox-config;
  programs.librewolf = librewolf-config;

  services.syncthing.enable = true;
}
