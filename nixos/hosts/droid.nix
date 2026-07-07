{
  pkgs,
  paths,
  username,
  homeDirectory,
  inputs,
  self,
  nix-index-database,
  channels,
  hostname,
  ...
}: {
  environment.packages = with pkgs; [
    bat
    bzip2
    diffutils
    eza
    fd
    file
    findutils
    git
    gnugrep
    gnupg
    gnused
    gnutar
    gzip
    pkgs.hostname
    htop
    jq
    killall
    man
    neovim
    procps
    ripgrep
    tzdata
    unzip
    util-linux
    wget
    xz
    zip
  ];

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "24.05";

  home-manager = {
    config = "${paths.home}/base.nix";
    extraSpecialArgs = {
      inherit inputs self paths username homeDirectory nix-index-database channels hostname;
    };
    backupFileExtension = "hm-bak";
    useGlobalPkgs = true;
  };
}
