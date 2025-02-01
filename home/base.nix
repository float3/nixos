{
  config,
  pkgs,
  username,
  nix-index-database,
  ...
}: let
  system = pkgs.system;
  homeDir = config.home.homeDirectory;
  myFish = myFlakes.packages.${system}.fish;
  myVM = myFlakes.packages.${system}.nixos-vm;
  myVim = myFlakes.packages.${system}.vim;
  myHelix = myFlakes.packages.${system}.helix;
  myGit = myFlakes.packages.${system}.git;
in {
  imports = [
    # nix-index-database.hmModules.nix-index
  ];

  home = {
    stateVersion = "24.11";
    enableNixpkgsReleaseCheck = true;
    username = "hill";
    homeDirectory = "/home/hill";

    sessionVariables.EDITOR = "nvim";
    sessionVariables.SHELL = "fish";
  };

  home.packages = [
  ];

  programs = {
    home-manager.enable = true;

    nix-index.enable = true;
    nix-index.enableFishIntegration = true;
    # nix-index-database.comma.enable = true;

    # fzf.enable = true;
    # fzf.enableZshIntegration = true;
    # lsd.enable = true;
    # lsd.enableAliases = true;
    # zoxide.enable = true;
    # zoxide.enableZshIntegration = true;
    # broot.enable = true;
    # broot.enableZshIntegration = true;

    direnv.enable = true;
    direnv.enableFishIntegration = true;
    direnv.nix-direnv.enable = true;

    alacritty = {
      enable = true;
      settings = {
        env.TERM = "xterm-256color";
        window = {
          opacity = 0.75;
        };
        font = {
          normal = "{ family = \"MonaspaceNeon\", style = \"Regular\" }";
        };
        selection.save_to_clipboard = true;
      };
    };

    git = {
      enable = true;
      delta.enable = true;
      delta.options = {
        line-numbers = true;
        side-by-side = true;
        navigate = true;
      };
      userEmail = "hill@hilll.dev";
      userName = "hill";
      extraConfig = {
        push = {
          default = "current";
          autoSetupRemote = true;
        };
        merge = {
          conflictstyle = "diff3";
        };
        diff = {
          colorMoved = "default";
        };
      };
    };
    # emacs = {
    #   enable = true;
    #   extraPackages = epkgs: [
    #     epkgs.nix-mode
    #     epkgs.magit
    #   ];
    # };
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };
}
