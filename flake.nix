{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # float3-flakes = {
    #   url = "github:float3/flakes";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # prismlauncher = {
    #   url = "github:Diegiwg/Prismlauncher-Cracked";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    ow-mod-man = {
      url = "github:ow-mods/ow-mod-man";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # trolley.url = "github:float3/webapp";

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

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };






  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    nix-on-droid,
    ...
  }: let
    lib = nixpkgs.lib;
    username = "hill";

    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];

    pkgsFor = system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

    forAllSystems = f:
      lib.genAttrs supportedSystems (system: f (pkgsFor system));

    paths = {
      root = ./.;
      nixos = ./nixos;
      home = ./home;
      hosts = ./nixos/hosts;
      modules = ./nixos/modules;
      roles = ./nixos/roles;
      vendor = ./nixos/vendor;
    };
    mkSpecialArgs = hostName: {
      inherit inputs self paths username;
      channels = {inherit nixpkgs;};
      hostname = hostName;
      nix-index-database = inputs.nix-index-database;
    };

    linuxHomeModules = [
      "${paths.home}/base.nix"
      "${paths.home}/linux.nix"
    ];

    desktopHomeModules =
      linuxHomeModules
      ++ [
        "${paths.home}/desktop.nix"
      ];

    mkHomeConfig = {
      system,
      homeDirectory,
      modules ? ["${paths.home}/base.nix"],
      name ? username,
    }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor system;
        extraSpecialArgs =
          (mkSpecialArgs name)
          // {
            inherit homeDirectory;
          };
        modules =
          modules
          ++ [
            {
              home.username = lib.mkDefault username;
              home.homeDirectory = lib.mkDefault homeDirectory;
              nixpkgs.config.allowUnfree = true;
            }
          ];
      };

    mkHomeManagerModule = hostName: homeModules: {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "hm-bak";
        extraSpecialArgs =
          (mkSpecialArgs hostName)
          // {
            homeDirectory = "/home/${username}";
          };
        users.${username}.imports = homeModules;
      };
    };

    mkNixosConfig = {
      hostName,
      system ? "x86_64-linux",
      homeModules ? linuxHomeModules,
      extraModules ? [],
    }:
      lib.nixosSystem {
        inherit system;
        specialArgs = inputs // mkSpecialArgs hostName;
        modules =
          [
            "${paths.hosts}/${hostName}/configuration.nix"
            home-manager.nixosModules.home-manager
            (mkHomeManagerModule hostName homeModules)
          ]
          ++ extraModules;
      };
  in {
    formatter = forAllSystems (pkgs: pkgs.alejandra);

    packages = forAllSystems (pkgs: {});

    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          alejandra
          fish
          gitleaks
          rustfmt
          shellcheck
          taplo
        ];

        shellHook = ''
          if [[ $- == *i* && -z "''${NIX_DEVELOP_FISH:-}" ]]; then
            export NIX_DEVELOP_FISH=1
            exec ${lib.getExe pkgs.fish}
          fi
        '';
      };
    });

    checks = forAllSystems (pkgs: {
      formatting =
        pkgs.runCommand "alejandra-check" {
          nativeBuildInputs = [pkgs.alejandra];
          src = self;
        } ''
          alejandra --check "$src"
          touch "$out"
        '';
    });

    nixosConfigurations = {
      laptop = mkNixosConfig {
        hostName = "laptop";
        homeModules = desktopHomeModules;
      };
      workstation = mkNixosConfig {
        hostName = "workstation";
        homeModules = desktopHomeModules;
      };
      hetzner = mkNixosConfig {hostName = "hetzner";};
      localserver = mkNixosConfig {hostName = "localserver";};
      macbook = mkNixosConfig {
        hostName = "macbook";
        homeModules = desktopHomeModules;
      };
      steamdeck = mkNixosConfig {
        hostName = "steamdeck";
        homeModules = desktopHomeModules;
      };
      thinkcentre = mkNixosConfig {hostName = "thinkcentre";};
      wsl = mkNixosConfig {hostName = "wsl";};
    };

    homeConfigurations = {
      hill = mkHomeConfig {
        system = "x86_64-linux";
        homeDirectory = "/home/${username}";
        modules =
          linuxHomeModules
          ++ [
            {targets.genericLinux.enable = true;}
          ];
      };

      macbook = mkHomeConfig {
        system = "aarch64-darwin";
        homeDirectory = "/Users/${username}";
        modules = [
          "${paths.home}/base.nix"
          "${paths.home}/macbook.nix"
        ];
      };
    };

    # docs = pkgs.runCommand "options-doc.md" {} ''
    #   cat ${optionsDoc.optionsCommonMark} | ${pkgs.gnused}/bin/sed -E 's|file://||g' | ${pkgs.gnused}/bin/sed -E 's|(\/nix\/store\/[^/]*)\/darwin\/modules|https:\/\/github.com\/float3\/nixos\/tree\/master\/darwin\/modules|g' | ${pkgs.gnused}/bin/sed -E 's|(\/nix\/store\/[^/]*)\/nixos\/modules|https:\/\/github.com\/float3\/nixos\/tree\/master\/nixos\/modules|g' | ${pkgs.gnused}/bin/sed -E 's|(\/nix\/store\/[^/]*)\/home\/modules|https:\/\/github.com\/float3\/nixos\/tree\/master\/home\/modules|g' > $out
    # '';

    # devShell = pkgs.mkShell {
    #   name = "nixos-configs devShell";
    #   buildInputs = with pkgs; [
    #     lefthook
    #     gitleaks # bug in pkgs.gitleaks currently
    #   ];
    # };

    nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
      extraSpecialArgs =
        inputs
        // mkSpecialArgs "droid"
        // {
          homeDirectory = "/data/data/com.termux.nix/files/home";
        };
      modules = ["${paths.hosts}/droid.nix"];
      home-manager-path = home-manager.outPath;
      pkgs = import nixpkgs {
        system = "aarch64-linux";
        config.allowUnfree = true;

        overlays = [
          nix-on-droid.overlays.default
          # add other overlays
        ];
      };
    };
  };
}
