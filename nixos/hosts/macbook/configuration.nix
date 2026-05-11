{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd.luks.devices."luks-28f911f1-d35f-452f-89fa-b705650f5227".device = "/dev/disk/by-uuid/28f911f1-d35f-452f-89fa-b705650f5227";
  };

  networking = {
    hostName = "macbook";
    networkmanager.enable = true;

    firewall.allowedTCPPorts = config.services.openssh.ports;
  };

  time.timeZone = "Europe/Berlin";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_IDENTIFICATION = "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "de_DE.UTF-8";
    };
  };

  services = {
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
    };

    printing.enable = true;

    pulseaudio.enable = false;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    openssh = {
      enable = true;
      settings = {
        PubkeyAuthentication = true;
        PasswordAuthentication = false;
      };
    };
  };

  security.rtkit.enable = true;

  users.users.hill = {
    isNormalUser = true;
    description = "hill";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      alejandra
      fish
      krabby
      thunderbird
    ];
  };

  programs = {
    firefox.enable = true;
    fish.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
  ];

  system.stateVersion = "25.11";
}
