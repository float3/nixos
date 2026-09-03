{
  config,
  pkgs,
  lib,
  username,
  ...
}: {
  users.users.${username}.extraGroups = ["kvm"];

  environment = {
    systemPackages =
      (with pkgs; [
        pavucontrol
        # dolphin
        # imv
        # openvr
        # reaper
        # vim
        # vlc
        alacritty
        android-tools
        kitty
        anki
        chromium
        castnow
        dunst
        emacs
        eww
        feh
        firefox
        gcs
        grayjay
        # gtk3 # for missing gsettings schemas with env variable
        crosspipe
        handbrake
        krita
        hexchat
        kdePackages.kdeconnect-kde
        keepassxc
        librewolf
        # lutris
        monaspace
        musescore
        mokuro
        mpv
        mullvad
        mullvad-compass
        obsidian
        pkg-configUpstream
        polybarFull
        pulseaudioFull
        polybar-pulseaudio-control
        qbittorrent
        rofi
        adwaita-icon-theme
        scrcpy
        spotify
        stremio-linux-shell
        syncplay-nogui
        syncplay
        telegram-desktop
        pay-respects
        thunderbird
        vesktop
        unzip
        wget
        karere
        wireplumber
        wofi
        yt-dlp
        (python314.withPackages (ps:
          with ps; [
            # argparse
            # openvr
            # psutil
            # pyglet
            # pygame
            # python-osc
            # requests
            # zeroconf
            # pypdf2
            # setuptools
          ]))
        (wrapOBS {
          plugins = with pkgs.obs-studio-plugins; [
            wlrobs
            obs-pipewire-audio-capture
          ];
        })
        (discord.override {
          withTTS = true;
          withVencord = true;
          withOpenASAR = true;
        })
      ])
      ++ (with pkgs.mpvScripts; [
        autoload
        mpv-playlistmanager
        quality-menu
        sponsorblock
        webtorrent-mpv-hook
      ]);
  };

  programs = {
    dconf.enable = true;
    nm-applet.enable = true;
    thunar.enable = true;
    xfconf.enable = true;
    thunar.plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];
    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-qt;
    };
  };

  services = {
    syncplay.enable = true;
    blueman.enable = true;
    mullvad-vpn = {
      enable = true;
      package = pkgs.mullvad-vpn;
      enableExcludeWrapper = true;
    };

    # emacs = {
    #   enable = true;
    #   package = pkgs.emacs-gtk;
    # };

    desktopManager.plasma6.enable = true;

    displayManager = {
      autoLogin = {
        user = username;
        enable = false;
      };
      sddm.enable = true;
    };

    pulseaudio.enable = false;

    # Enable touchpad support (enabled default in most desktopManager).
    libinput = {
      enable = true;
      mouse = {
        accelProfile = "flat";
      };
      touchpad = {
        accelProfile = "flat";
      };
    };
    xserver = {
      desktopManager = {
        runXdgAutostartIfNone = true;
      };

      xkb = {
        layout = "us,de";
        # variant = "";
        # model = "pc105";
        options = "grp:win_space_toggle";
      };
      excludePackages = with pkgs; [
        xterm
      ];
    };
  };

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      carlito
      dejavu_fonts
      ipafont
      kochi-substitute
      source-code-pro
      ttf_bitstream_vera
      font-awesome
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      siji
      source-han-sans
      source-han-serif
    ];
    fontDir.enable = true;
    fontconfig = {
      defaultFonts = {
        monospace = [
          "MonaspaceXenon"
          "Noto Mono"
          "Source Han Mono"
        ];
        serif = [
          "MonaspaceRadon"
          "Noto Serif"
          "Source Han Serif"
        ];
        sansSerif = [
          "MonaspaceArgon"
          "Noto Sans"
          "Source Han Sans"
        ];
      };
    };
  };
}
