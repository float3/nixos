{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-lts.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nixos-hardware.url = "github:nixos/nixos-hardware/master";

    nixos-wsl.url = "github:nix-community/NixOS-WSL";

    # nix-index-database = {
    #   url = "github:nix-community/nix-index-database";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    jovian-nixos = {
      url = "git+https://github.com/Jovian-Experiments/Jovian-NixOS?ref=development";
      flake = false;
    };

    # home-manager = {
    #   url = "github:nix-community/home-manager";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    nur.url = "github:nix-community/NUR";

    flatpaks.url = "github:GermanBread/declarative-flatpak/stable";

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hill-keys = {
      url = "https://github.com/float3.keys";
      flake = false;
    };

    redmage-keys = {
      url = "https://github.com/akaimage.keys";
      flake = false;
    };

    divayth-keys = {
      url = "https://github.com/e00e.keys";
      flake = false;
    };

    pema-keys = {
      url = "https://github.com/pema99.keys";
      flake = false;
    };

    mark-keys = {
      url = "https://github.com/nyrox.keys";
      flake = false;
    };

    stephen-keys = {
      url = "https://gitlab.scd31.com/stephen.keys";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixpkgs-lts,
    nixos-hardware,
    nixos-wsl,
    # nix-index-database,
    disko,
    jovian-nixos,
    # home-manager,
    nur,
    flatpaks,
    nix-on-droid,
    hill-keys,
    redmage-keys,
    divayth-keys,
    pema-keys,
    mark-keys,
    stephen-keys,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      arch =
        if pkgs.lib.hasInfix "aarch64" "${system}"
        then "aarch64"
        else "x86_64";

      linuxSystem = "${arch}-linux";

      paths = {
        nixos = ./nixos;
        home = ./home;
        hosts = ./nixos/hosts;
        modules = ./nixos/modules;
        roles = ./nixos/roles;
        vendor = ./nixos/vendor;
      };

      mkNixosConfig = hostName: extraModules:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs =
            inputs
            // {
              inherit
                inputs
                self
                paths
                ;
              # nix-index-database ;
              channels = {
                inherit nixpkgs nixpkgs-unstable;
              };
              username = "hill";
              hostname = hostName;
            };
          modules =
            [
              "${paths.hosts}/${hostName}/configuration.nix"
              # home-manager.nixosModules.home-manager
            ]
            ++ extraModules;
        };
    in {
      formatter = pkgs.alejandra;

      packages.nixosConfigurations = {
        laptop = mkNixosConfig "laptop" [];
        workstation = mkNixosConfig "workstation" [];
        hetzner = mkNixosConfig "hetzner" [];
        steamdeck = mkNixosConfig "steamdeck" [];
        wsl = mkNixosConfig "wsl" [];
      };

      packages.nixOnDroidConfigurations = {
        default = nix-on-droid.lib.nixOnDroidConfiguration {
          extraSpecialArgs = inputs;
          modules = ["${paths.hosts}/droid.nix"];
        };
      };
    });
}
