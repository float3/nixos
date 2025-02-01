{
  username,
  hostname,
  config,
  pkgs,
  lib,
  inputs,
  float3-keys,
  paths,
  ...
}: {
  imports = [];

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  boot = {
    # kernelPackages = pkgs.linuxPackages_zen;
  };

  networking = {
    # nftables = {
    #   enable = true;
    # };
    hostName = "${hostname}";
    # nat = {
    #   enable = true;
    #   enableIPv6 = true;
    #   #   externalInterface = "etho0";
    #   #   internalInterfaces = [ "wg0" ];
    # };
    firewall = {
      allowedTCPPorts = config.services.openssh.ports ++ [53 57621];
      allowedUDPPorts = [53 5353];
      enable = true;
    };
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
    networkmanager.enable = true;
    # wireguard.interfaces = { };
  };

  console = {
    keyMap = "us";
  };

  hardware.enableAllFirmware = true;

  time.timeZone = "Atlantic/Reykjavik";

  i18n = {
    defaultLocale = "en_SG.UTF-8";
    extraLocaleSettings = {
      # LANG = "zh_TW.UTF-8";
      # LANGUAGE = "zh_TW.UTF-8";
      # LC_ALL = "zh_TW.UTF-8";
      LC_ADDRESS = "zh_TW.UTF-8";
      LC_IDENTIFICATION = "zh_TW.UTF-8";
      LC_MEASUREMENT = "zh_TW.UTF-8";
      LC_MONETARY = "zh_TW.UTF-8";
      LC_NAME = "zh_TW.UTF-8";
      LC_NUMERIC = "zh_TW.UTF-8";
      LC_PAPER = "zh_TW.UTF-8";
      LC_TELEPHONE = "zh_TW.UTF-8";
      LC_TIME = "zh_TW.UTF-8";
    };
  };

  nix = {
    registry = {
      nixpkgs = {
        flake = inputs.nixpkgs;
      };
    };
    nixPath = [
      "nixpkgs=${inputs.nixpkgs.outPath}"
      "nixos-config=${config.users.users.${username}.home}/.config/nixos/nixos/hosts/${config.networking.hostName}/configuration.nix"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];
    settings = {
      accept-flake-config = true;
      trusted-users = ["root" "nix-ssh" username];
      auto-optimise-store = true;
      sandbox = true;
    };
    sshServe = {
      enable = true;
      write = true;
      protocol = "ssh";
      keys = config.users.users.${username}.openssh.authorizedKeys.keys;
    };
    package = pkgs.nixVersions.stable;
    extraOptions = "experimental-features = nix-command flakes";
    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "";
    };
  };

  system = {
    # copySystemConfiguration = true;
    autoUpgrade = {
      flake = "${config.users.users.${username}.home}/.config/nix/";
      enable = true;
      flags = ["update" "--commit-lock-file"];
      allowReboot = false;
    };
  };

  zramSwap.enable = true;

  environment = {
    shells = [pkgs.fish];
    enableAllTerminfo = true;

    variables = rec {
      EDITOR = "nvim";
      GIT_EDTIOR = "nvim";
      VISUAL = "nvim";
      LAMBDA = "λ";
      DOTNET_CLI_TELEMTRY_OPTOUT = "true";

      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_STATE_HOME = "$HOME/.local/state";

      # Not officially in the specification
      XDG_BIN_HOME = "$HOME/.local/bin";

      DOTNET_ROOT = "${pkgs.dotnet-sdk_8}";
      DOTNET_TOOLS = "$HOME/.dotnet/tools";

      NIXOS_CONFIG_PATH = "${config.users.users.${username}.home}/.config/nix/hosts/${config.networking.hostName}/configuration.nix";
      NIXOS_FLAKE = "${config.users.users.${username}.home}/.config/nix/flake.nix";
      NIX_INDEX_DATABASE = "${config.users.users.${username}.home}/.cache/nix-index";
      NIXPKGS_ALLOW_FREE = "1";

      PATH = [
        "${XDG_BIN_HOME}"
        "${DOTNET_TOOLS}"
        "$HOME/.cargo/bin"
      ];
    };

    systemPackages =
      (with pkgs; [
        bat
        eza
        fastfetch
        file
        fd
        git
        git-lfs
        htop
        ncdu
        magic-wormhole
        neovim
        ripgrep
        ripgrep-all
        syncthing
        topgrade
        thefuck
        pv
        alejandra
      ])
      ++ (with pkgs.fishPlugins; [
        sponge
        bass
      ])
      ++ (with pkgs.vimPlugins; [
        everforest
        lazy-nvim
        treesj
      ])
      ++ (with pkgs.fishPlugins; [])
      ++ (with pkgs.emacsPackages; []);
  };

  # home-manager.users.${username} = {
  #   imports = [
  #     "${paths.home}/home.nix"
  #   ];
  # };

  users = {
    # defaultUserShell = pkgs.fish;
    users = {
      root = {
        isNormalUser = false;
        home = "/root";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        # packages = with pkgs; [];

        hashedPassword = config.users.users.${username}.hashedPassword;
        openssh.authorizedKeys = {
          keys = config.users.users.${username}.openssh.authorizedKeys.keys;
          keyFiles = config.users.users.${username}.openssh.authorizedKeys.keyFiles;
        };
      };

      ${username} = {
        isNormalUser = true;
        description = username;
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        # packages = with pkgs; [];

        hashedPassword = "$y$j9T$/JMhCueHQitv9EUkqbyqd.$.f/3jGmKfb17e20IDRVyIa7Csib9WNgdLhUUb8uVey8";
        openssh.authorizedKeys = {
          keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG04EoKVJnby/inn+vt7Jh0X9Yd22tIrC5wnE6Xf2jFh pchill"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEdafTHCg+N8xdx68Ek9DwlY1spwlwdVhZlrafOdXuUL pcroot"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP0Wlnrq0zb0M6VLrQ4f6n6wB6NP5/T8RdV9qpWcr3OR laptophill"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/mAHdDcDGHsV7Ub90v0bA+HV3DJIM/XIX7R+IbSOfN laptoproot"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDgpZtquYpnhCxMg7piBD3Y+exV0lbyMPEMDS25Fb5MP phone"
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC+mxF9W8N/sXSCZnFIgJzkaj9inmD2tMsWRU+PXyJ0MC51/emf1GJzagSycUk+P6z1A04fGm8cOHOgAQL6AdO/5AzT7naELOmd4s6eNoAPWM7nKVfJjGWgdfsFoHRzAFoQJbtSmTTNbgqJxXSHyLEauS1vIRMurmF4oPCDBAMRj7mOVdfs3y5lCwYXxLzOWFbtjOZeHpdHt3nIHQgcO9iHPLcmtKQIP0IW7+J9FjDcc8zv6IWNo3F5q2hjHy64IsgJ7uF1kFstr9I+b7PDZv3rbsp0GBJlB0CKZCxm2JZ9JKNlVGdHp+fdA+xYDXRGlLb5CU/XxMuQmVXqp5ND5qtemKSwJx8eCMqSaUqbJnkUL3VcvJgaEvNHYXYyXCN62IDlNqVyPNhZegJstW7WBJjyNi9RM3waTr51MISNy9KnPe57QQWJJAhMcVPFPET/BOWWHs4sHwqb4CngVYDj0IHnVNj/yuuDkbGhLAcpO2eBT5GxzVrzvwiceADyRoSwpp0= groupinfra\davidluca.weil@DE-L088076"
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC1byF77iQy3fK8DSgCGdO1Oo5BDiMdIQJr1Mix5olHyEm7DxkcJ4Qj26gJnWJvFhA/20co2a2pghuPipXaWOPCcYgleuEThJPcow2zQp8pjm+hm86Ooz8bj2DjBMEqxQU9lsKbrpradQm3rho9JEM8bwc9BR8ilyRP9ecSfmuRYoDyUWNcxpEXcviqMAbvCxz0MhS+ZV+3YtSHDRDBGvDU45VTa7il8RpBvEvcnkRaXWjf9dqqCAWvELI5mZND6xMPxZ2ljXI5V8jVEs7q1iTLH8BsdkkW54Gi54Vyeuh/3Efx2sdRBPdL410hEvjUyZiSo3fSXNWbstMeAQ/0ph7mu+CVvf4YTMc+Tojgd3eGS3PsZbrokDbYNRN32jFV+3480ZjXWcK6XtBuiQyFywivmm73LZayFsCDkxp8sBU5I4L70Z8r9KpC2L7zOgxPfdP3HmoVA5/5PDeHexg0gfpfvOvJ5L+fsQgtgTryqLRFwbUG6Ob3zPIAd2/8BGCQhy8="
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAhFNsOJOIN3kAhV5smuLSqwaXeQt0CvF18wM27gt9H5 jaewon"
          ];
          keyFiles = [float3-keys.outPath];
        };
      };
    };
  };

  programs = {
    nix-ld.enable = true;
    nix-index = {
      enable = true;
      enableFishIntegration = true;
    };
    command-not-found.enable = false;
    fish.enable = true;
    tmux.enable = true;
    bash = {
      interactiveShellInit = ''
        if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]; then
          shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
          exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
        fi
      '';
    };
  };

  services = {
    fail2ban = {
      enable = true;
    };

    openssh = {
      enable = true;
      ports = [22];
      settings = {
        PasswordAuthentication = false;
        UseDns = true;
        X11Forwarding = false;
        PermitRootLogin = "prohibit-password";
      };
    };
    # syncthing = {
    # enable = true;
    # };
  };

  security.sudo.wheelNeedsPassword = true;

  virtualisation = {
    # docker = {
    #   enable = true;
    #   enableOnBoot = true;
    #   autoPrune.enable = true;
    # };
  };
}
