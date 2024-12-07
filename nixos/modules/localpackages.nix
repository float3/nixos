{
  config,
  pkgs,
  lib,
  username,
  ...
}: {
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
        anki
        arandr
        chromium
        castnow
        dunst
        emacs
        eww
        feh
        firefox
        gcs
        # gtk3 # for missing gsettings schemas with env variable
        helvum
        handbrake
        hexchat
        plasma5Packages.kdeconnect-kde
        keepassxc
        librewolf
        lutris
        monaspace
        musescore
        mokuro
        mpv
        mullvad
        mullvad-closest
        obsidian
        picom # xserver
        pkg-configUpstream
        polybarFull
        pulseaudioFull
        polybar-pulseaudio-control
        qbittorrent
        rofi
        adwaita-icon-theme
        scrcpy
        spotify
        stremio
        syncplay-nogui
        syncplay
        telegram-desktop
        thefuck
        thunderbird
        vesktop
        unzip
        wget
        whatsapp-for-linux
        winePackages.fonts
        winetricks
        wineWowPackages.unstableFull
        wireplumber
        wofi
        yt-dlp
        (python313Full.withPackages (ps:
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
        (discord-canary.override {
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
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
    dconf.enable = true;
    gamemode.enable = true;
    nm-applet.enable = true;
    thunar.enable = true;
    xfconf.enable = true;
    thunar.plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
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
    # Enable CUPS to print documents.
    printing.enable = true;

    emacs = {
      enable = true;
      package = pkgs.emacs-gtk;
    };

    desktopManager.plasma6.enable = true;

    displayManager = {
      autoLogin = {
        user = username;
        enable = false;
      };
      sddm.enable = true;
    };

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
      enable = true;
      desktopManager = {
        runXdgAutostartIfNone = true;
      };
      windowManager.i3.enable = true;

      xkb = {
        layout = "us,de";
        # variant = "";
        # model = "pc105";
        options = "grp:win_space_toggle";
      };
      excludePackages = with pkgs; [
        xterm
        konsole
      ];
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;
      pulse.enable = true;
      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      # media-session.enable = true;
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
      noto-fonts-emoji
      siji
      source-han-sans
      source-han-sans-japanese
      source-han-serif-japanese
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
