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
      # The programs.fish, programs.git and programs.delta modules are gone:
      # they installed the same binaries, so keeping both would collide, and
      # their settings now live in the flake configs instead.
      #
      # vim replaces the plain nixpkgs neovim: it is a neovim wrapper built
      # with vimAlias/viAlias, so shipping both would collide on bin/nvim.
      inputs.float3-flakes.packages.${pkgs.system}.fish
      inputs.float3-flakes.packages.${pkgs.system}.git
      inputs.float3-flakes.packages.${pkgs.system}.tmux
      inputs.float3-flakes.packages.${pkgs.system}.topgrade
      inputs.float3-flakes.packages.${pkgs.system}.vim
    ];
  };

  programs = {
    home-manager.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
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
