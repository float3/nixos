{
  config,
  pkgs,
  paths,
  username,
  lib,
  ...
}: {
  imports = [
    ./localpackages.nix
    "${paths.roles}/gaming.nix"
  ];

  boot = {
    supportedFilesystems = ["ntfs"];
    loader = {
      grub.enableCryptodisk = true;
      systemd-boot.enable = true;
      efi = {
        efiSysMountPoint = "/boot";
        canTouchEfiVariables = true;
      };
    };
  };

  environment = {
    variables = rec {
      BROWSER = "librewolf";

      # XMODIFIERS = "@im=fcitx5";
      XMODIFIER = "@im=fcitx5";
      SDL_IM_MODULE = "fcitx5";
      GLFW_IM_MODULE = "fcitx5";
      # GSETTINGS_SCHEMA_DIR = "/run/current-system/sw/share/gsettings-schemas/gtk+3-3.24.41/glib-2.0/schemas";
    };
  };

  # networking = {
  #   nftables = {
  #     ruleset = "
  #   table inet excludeTraffic {
  #     chain allowIncoming {
  #       type filter hook input priority -100; policy accept;
  #          udp dport 22 ct mark set 0x00000f41;
  #          tcp dport 22 ct mark set 0x00000f41;
  #        }
  #     }";
  #   };
  # };

  nix = {
    # buildMachines = [
    #   {
    #     hostName = "builder";
    #     system = "x86_64-linux";
    #     protocol = "ssh";
    #     systems = ["x86_64-linux" "aarch64-linux"];
    #     maxJobs = 1;
    #     speedFactor = 2;
    #     supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
    #     mandatoryFeatures = [];
    #   }
    # ];

    # settings = {
    #   # substituters = ["ssh://builder"];
    #   # trusted-substituters = ["ssh://builder"];
    #   # trusted-public-keys = [
    #   #   "builder:8VTBCw/IErkLPdmbV8uSfhKLTmqBSJvi7PjisOJQGmQ="
    #   # ];
    # };

    # distributedBuilds = true;
    # extraOptions = ''
    #   builders-use-substitutes = true
    # '';
  };

  console = {
    # font = "/run/current-system/sw/share/fonts/truetype/MonaspaceXenon-Regular.ttf";
  };

  # sound.enable = false;
  security = {
    rtkit.enable = true;
    polkit.enable = true;
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        libva
      ];
    };
  };

  services = {
    pulseaudio.enable = false;
  };

  programs = {
    ssh.extraConfig = ''
      Host builder
        Hostname 168.119.167.115
        IdentitiesOnly yes
        IdentityFile /root/.ssh/nixremote
        User nixremote
        StrictHostKeyChecking accept-new
      Host PC
        Hostname 192.168.0.105
        IdentitiesOnly yes
        User ${username}
        StrictHostKeyChecking accept-new
      Host server
        Hostname 168.119.167.115
        IdentitiesOnly yes
        User root
        StrictHostKeyChecking accept-new
    '';
  };

  # systemd.services = {
  #   "sshd" = {
  #     serviceConfig = {
  #       RestartSec = "20s";
  #       ExecStart = lib.mkForce "${pkgs.mullvad-vpn}/bin/mullvad-exclude ${pkgs.openssh}/bin/sshd -D -f /etc/ssh/sshd_config";
  #     };
  #   };
  # };

  i18n = {
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-chinese-addons
        fcitx5-hangul
        fcitx5-gtk
        fcitx5-skk
        fcitx5-skk-qt
      ];
    };
  };

  virtualisation = {
    lxd.enable = true;
  };
}
