{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-lts.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nixos-hardware.url = "github:nixos/nixos-hardware/master";

    nixos-wsl.url = "github:nix-community/NixOS-WSL";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jovian-nixos = {
      url = "git+https://github.com/Jovian-Experiments/Jovian-NixOS?ref=development";
      flake = false;
    };

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
    nix-index-database,
    disko,
    jovian-nixos,
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
        nixosPath = ./nixos;
        homePath = ./home;
        hostsPath = ./nixos/hosts;
        modulesPath = ./nixos/modules;
        rolesPath = ./nixos/roles;
        vendorPath = ./nixos/vendor;
      };

      mkNixosConfig = hostName: modules:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs =
            inputs
            // {
              inherit inputs self nix-index-database paths;
              channels = {
                inherit nixpkgs nixpkgs-unstable;
              };
              username = "hill";
              hostname = hostName;
            };
          modules = modules;
        };
    in {
      formatter = pkgs.alejandra;

      packages.nixosConfigurations = {
        laptop = mkNixosConfig "laptop" [./nixos/hosts/laptop/configuration.nix];
        workstation = mkNixosConfig "workstation" [./nixos/hosts/workstation/configuration.nix];
        hetzner = mkNixosConfig "hetzner" [./nixos/hosts/hetzner/configuration.nix disko.nixosModules.disko];
        steamdeck = mkNixosConfig "steamdeck" [./nixos/hosts/steamdeck/configuration.nix];
        wsl = mkNixosConfig "wsl" [./nixos/hosts/wsl/configuration.nix];
      };

      packages.nixOnDroidConfigurations = {
        default = nix-on-droid.lib.nixOnDroidConfiguration {
          extraSpecialArgs = inputs;
          modules = [./nixos/hosts/droid.nix];
        };
      };
    });
}
