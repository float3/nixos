{
  config,
  pkgs,
  lib,
  username ? "hill",
  homeDirectory ? (
    if pkgs.stdenv.isDarwin
    then "/Users/${username}"
    else "/home/${username}"
  ),
  ...
}: {
  home = {
    stateVersion = "24.11";
    enableNixpkgsReleaseCheck = true;
    username = lib.mkDefault username;
    homeDirectory = lib.mkDefault homeDirectory;

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      SHELL = "fish";
    };

    packages = with pkgs; [
      bat
      eza
      fd
      file
      htop
      jq
      magic-wormhole
      neovim
      pay-respects
      pv
      ripgrep
      tldr
      tree
      unzip
      wget
      zip
    ];
  };

  programs = {
    home-manager.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    fish = {
      enable = true;
      interactiveShellInit = ''
        set -gx EDITOR nvim
      '';
    };

    git = {
      enable = true;
      signing.format = "openpgp";
      settings = {
        user = {
          email = "hill@hilll.dev";
          name = "hill";
        };
        push = {
          default = "current";
          autoSetupRemote = true;
        };
        merge.conflictstyle = "diff3";
        diff.colorMoved = "default";
        init.defaultBranch = "master";
      };
    };

    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        line-numbers = true;
        side-by-side = true;
        navigate = true;
      };
    };

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        server = {
          hostname = "168.119.167.115";
          user = username;
          identitiesOnly = true;
        };
        localserver = {
          hostname = "192.168.178.96";
          user = username;
          identitiesOnly = true;
        };
        laptop = {
          hostname = "192.168.178.175";
          user = username;
          identitiesOnly = true;
        };
        thinkcentre = {
          hostname = "thinkcentre.local";
          user = username;
          identitiesOnly = true;
        };
      };
    };
  };
}
