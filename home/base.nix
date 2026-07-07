{
  config,
  pkgs,
  lib,
  inputs,
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
      # inputs.float3-flakes.packages.${pkgs.system}.fish
      # inputs.float3-flakes.packages.${pkgs.system}.git
      # inputs.float3-flakes.packages.${pkgs.system}.tmux
      # inputs.float3-flakes.packages.${pkgs.system}.vim
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
      settings = {
        hetzner = {
          HostName = "traeumerei.dev";
          User = username;
          IdentitiesOnly = true;
        };
        server = {
          HostName = "168.119.167.115";
          User = username;
          IdentitiesOnly = true;
        };
        localserver = {
          HostName = "192.168.178.96";
          User = username;
          IdentitiesOnly = true;
        };
        laptop = {
          HostName = "192.168.178.175";
          User = username;
          IdentitiesOnly = true;
        };
        thinkcentre = {
          HostName = "thinkcentre.local";
          User = username;
          IdentitiesOnly = true;
        };
      };
    };
  };
}
