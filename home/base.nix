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
      pay-respects
      pv
      ripgrep
      tldr
      tree
      unzip
      wget
      zip
      # From github:float3/flakes, which bakes the config into the store.
      #
      # fish and git are deliberately NOT taken from there: programs.fish and
      # programs.git below already install those binaries, so both would
      # collide, and the flake's gitconfig sets a different commit address
      # (github@hill.io) than the one configured below.
      #
      # vim replaces the plain nixpkgs neovim: it is a neovim wrapper built
      # with vimAlias/viAlias, so shipping both would collide on bin/nvim.
      inputs.float3-flakes.packages.${pkgs.system}.tmux
      inputs.float3-flakes.packages.${pkgs.system}.vim
      inputs.float3-flakes.packages.${pkgs.system}.topgrade
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
