{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # prismlauncher = {
    #   url = "github:Diegiwg/Prismlauncher-Cracked";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    ow-mod-man = {
      url = "github:ow-mods/ow-mod-man";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # trolley.url = "github:float3/webapp";

    # myFlakes.url = "git+ssh://git@github.com/float3/flakes.git";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";

    nixos-wsl.url = "github:nix-community/NixOS-WSL";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # jovian-nixos = {
    #   url = "git+https://github.com/Jovian-Experiments/Jovian-NixOS?ref=development";
    #   flake = false;
    # };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nur.url = "github:nix-community/NUR";

    # flatpaks.url = "github:GermanBread/declarative-flatpak/stable";

    # nix-on-droid = {
    #   url = "github:nix-community/nix-on-droid/release-23.05";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    float3-keys = {
      url = "https://github.com/float3.keys";
      flake = false;
    };

    akaimage-keys = {
      url = "https://github.com/akaimage.keys";
      flake = false;
    };

    e00e-keys = {
      url = "https://github.com/e00e.keys";
      flake = false;
    };

    pema99-keys = {
      url = "https://github.com/pema99.keys";
      flake = false;
    };

    nyrox-keys = {
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
    # prismlauncher,
    ow-mod-man,
    # trolley,
    # myFlakes,
    nixos-hardware,
    nixos-wsl,
    nix-index-database,
    # jovian-nixos,
    home-manager,
    # nur,
    # flatpaks,
    # nix-on-droid,
    float3-keys,
    akaimage-keys,
    e00e-keys,
    pema99-keys,
    nyrox-keys,
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
                nix-index-database
                ;
              channels = {
                inherit
                  nixpkgs
                  ;
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

      packages = {
        nixosConfigurations = {
          laptop = mkNixosConfig "laptop" [];
          workstation = mkNixosConfig "workstation" [];
          hetzner = mkNixosConfig "hetzner" [];
          steamdeck = mkNixosConfig "steamdeck" [];
          wsl = mkNixosConfig "wsl" [];
        };

        # homeConfigurations = {
        #   hill = home-manager.lib.homeManagerConfiguration {
        #     inherit pkgs;
        #     modules = [
        #       # ./home/desktop.nix
        #       # ./home/base.nix
        #       # ./home/linux.nix
        #       # ./home/linux/desktop.nix
        #       # ./home/linux/i3.nix
        #       # ./home/linux/hyprland.nix
        #       # (import myFlakes.pacakges.${system}.gnome-dconf)
        #       {
        #         # Home-Manager specific nixpkgs config
        #         nixpkgs.config = {
        #           allowUnfree = true;
        #         };
        #         home = {
        #           username = "hill";
        #           homeDirectory = "/home/hill";
        #         };
        #         fonts.fontconfig.enable = true;
        #         # programs.home-manager.enable = true;
        #         targets.genericLinux.enable = true;
        #         home.packages = [
        #           # pkgs.docker-client
        #           (pkgs.nerdfonts.override {fonts = ["Hack" "DroidSansMono" "JetBrainsMono"];})
        #           myFlakes.packages.${system}.git
        #           myFlakes.packages.${system}.vim
        #         ];
        #         # home.file."bin/home-switch" = {
        #         #   enable = true;
        #         #   executable = true;
        #         #   text = ''
        #         #     #!/usr/bin/env bash
        #         #     git clone https://github.com/float3/nixos ~/opt/nixos-configs &>/dev/null || true
        #         #     ## OS-specific support (mostly, Ubuntu vs anything else)
        #         #     ## Anything else will use nixpkgs
        #         #     EXTRA_ARGS=""
        #         #     if grep -iq Ubuntu /etc/os-release
        #         #     then
        #         #       version="$(grep VERSION_ID /etc/os-release | cut -d'=' -f2 | tr -d '"')"
        #         #       ## Support for Ubuntu 22.04
        #         #       if [[ "$version" == "22.04" ]]
        #         #       then
        #         #         EXTRA_ARGS="--override-input nixpkgs github:nixos/nixpkgs/nixos-22.05"
        #         #       fi
        #         #       if [[ "$version" == "24.04" ]]
        #         #       then
        #         #         EXTRA_ARGS="--override-input nixpkgs github:nixos/nixpkgs/nixos-24.05"
        #         #       fi
        #         #     fi
        #         #     nix --extra-experimental-features 'nix-command flakes' run "$HOME/opt/nixos-configs#homeConfigurations.hill.activationPackage" --impure $EXTRA_ARGS
        #         #   '';
        #         # };
        #       }
        #       # hyprland.homeManagerModules.default
        #       # ./home/linux/hyprland.nix
        #     ];
        #     extraSpecialArgs = inputs;
        #   };
        # };

        # nixOnDroidConfigurations = {
        #   default = nix-on-droid.lib.nixOnDroidConfiguration {
        #     extraSpecialArgs = inputs;
        #     modules = ["${paths.hosts}/droid.nix"];
        #     # home-manager-path = home-manager.outPath;
        #   };
        # };

        # docs = pkgs.runCommand "options-doc.md" {} ''
        #   cat ${optionsDoc.optionsCommonMark} | ${pkgs.gnused}/bin/sed -E 's|file://||g' | ${pkgs.gnused}/bin/sed -E 's|(\/nix\/store\/[^/]*)\/darwin\/modules|https:\/\/github.com\/float3\/nixos\/tree\/master\/darwin\/modules|g' | ${pkgs.gnused}/bin/sed -E 's|(\/nix\/store\/[^/]*)\/nixos\/modules|https:\/\/github.com\/float3\/nixos\/tree\/master\/nixos\/modules|g' | ${pkgs.gnused}/bin/sed -E 's|(\/nix\/store\/[^/]*)\/home\/modules|https:\/\/github.com\/float3\/nixos\/tree\/master\/home\/modules|g' > $out
        # '';

        devShell = pkgs.mkShell {
          name = "nixos-configs devShell";
          buildInputs = with pkgs; [
            lefthook
            gitleaks # bug in pkgs.gitleaks currently
          ];
        };
      };
    });
}
