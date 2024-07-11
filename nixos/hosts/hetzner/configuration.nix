let
  domain = "traeumerei.dev";
in
  {
    username,
    paths,
    modulesPath,
    config,
    lib,
    pkgs,
    float3-keys,
    akaimage-keys,
    e00e-keys,
    pema99-keys,
    nyrox-keys,
    stephen-keys,
    ...
  }: {
    imports = [
      ./hardware-configuration.nix
      (modulesPath + "/installer/scan/not-detected.nix")
      "${paths.modules}/shared.nix"
      "${paths.modules}/builder.nix"

      (builtins.fetchTarball {
        # Pick a release version you are interested in and set its hash, e.g.
        url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-24.05/nixos-mailserver-nixos-24.05.tar.gz";
        # To get the sha256 of the nixos-mailserver tarball, we can use the nix-prefetch-url command:
        # release="nixos-23.05"; nix-prefetch-url "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz" --unpack
        sha256 = "sha256:0clvw4622mqzk1aqw1qn6shl9pai097q62mq1ibzscnjayhp278b";
      })
    ];

    boot = {
      loader = {
        grub = {
          efiSupport = true;
          efiInstallAsRemovable = true;
          devices = ["/dev/sdb"];
        };
      };
    };

    users = {
      users = {
        # films = {
        #   isNormalUser = true;
        #   home = "/mnt/volume/films";
        #   extraGroups = [];
        #   shell = "/run/current-system/sw/bin/bash";
        #   openssh.authorizedKeys = {
        #     keys = [
        #       "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKJL2GzHptrg5cAWk8y6ORC0A26N6e0qYc760SYU3+5h redmage"
        #       "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCpavb0ihCZ0EVdizKo8bGxnDoP7qFinaVBUNSw3K28Q7NVYssXQXaVyW8oNnjT4HHx08JR5M3cagQxmJhHoerU3NIazo5eKuP3sMciYU1O+7mTMGPB4STp+C31oP5mfa0UBL6/4e0Q7e2zMoTl6DWKKLfYbRdwgSjOeLB2Dmj8auAxNQlItI1bMcBwdQEnK4N+aWhJjRiIUkYRZAd+O0jQ7H5R9vUCKSMyvrEw4OExuy8ASKpPJTN8pyXyP3V5RM/9xSnFhelU+t9Y1EYelGFM6tuYFCCB1Xf7XltLKzJTUbFz0hILXimksNC38KkLtalbHnOahfndUiW70+WI4ABqPBGA7butLAuxsNRkjKo3/GNH/hgmo34HApUbMw/fKJdijygKc7xuG43OIt9pePPAbQysLIAX11Kmzy2aX+K2EuNSrNY5GtSuu4ChtXNSvD7KtzfbGk00g29HnFXtYWA9Hq3GIEnp4PiDjtQTn1qgLRwn0/4Ikdm5e5KMzGwluj0c5JJ3N7zs3L+g1Cel9V8czlb/F8um4OXY+fdky8J7EIybFhBiB0x03/U3Eole8bToq0HIAR4nkhudagz7czmY5UFLyVHj9YRBEfzdTFT5MsUwFeZCyHUBpRAydapDQoGUh3QP8F4XC0W8WiAKN5ryITeOle0yn5NQWxIXNQzTJw== pemamalling@gmail.com"
        #       "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDgiROaYCJa/f9CKEUsK+1HE1GLcElWhdW8VH6KJKkZS div1"
        #       "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEnaNznvKxpKNcxR47TF4PBnKilQyA/aEOxuj4+QJIcX div2"
        #       "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK1C1c2Rv/iIgXAFMdp4+UVnZxDLzQXbQ5Gsf0jSPzvh cutestpixelkit@gmail.com"
        #     ];
        #     keyFiles = [
        #       float3-keys.outPath
        #       akaimage-keys.outPath
        #       e00e-keys.outPath
        #       pema99-keys.outPath
        #       nyrox-keys.outPath
        #       stephen-keys.outPath
        #     ];
        #   };
        # };
      };
    };

    environment = {
      shells = [pkgs.fish];
      enableAllTerminfo = true;

      systemPackages = with pkgs; [
        ffmpeg
        nodejs_20
      ];
    };

    programs = {};

    networking = {
      firewall = {
        allowedTCPPorts = [80 443 5000 6697 8080 8384 22000 config.services.webdav.settings.port];
        allowedUDPPorts = [22000 21027];
      };
      networkmanager = {
        unmanaged = ["interface-name:ens10"];
      };
    };

    services = {
      postgresql = {
        enable = true;
        enableTCPIP = true;
        settings = {
          unix_socket_directories = "/run/postgresql";
        };
      };
      nginx = {
        recommendedTlsSettings = true;
        recommendedOptimisation = true;
        recommendedProxySettings = true;
        recommendedGzipSettings = true;
        enable = true;
        virtualHosts = {
          "${config.services.nextcloud.hostName}" = {
            forceSSL = true;
            enableACME = true;
          };
          "${config.services.onlyoffice.hostname}" = {
            forceSSL = true;
            enableACME = true;
          };
          "${domain}" = {
            addSSL = true;
            enableACME = true;
            # serverAliases = ["www.${domain}"];
            root = "/mnt/volume/${domain}";
          };
          "znc.${domain}" = {
            forceSSL = true; # Force SSL redirection
            enableACME = true; # Enable Let's Encrypt for SSL certificates
            locations = {
              "/" = {
                proxyPass = "http://127.0.0.1:5000";
                extraConfig = ''
                  proxy_set_header Host $host;
                  proxy_set_header X-Real-IP $remote_addr;
                  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_set_header X-Forwarded-Proto $scheme;
                '';
              };
            };
          };
          "problem.${domain}" = {
            forceSSL = true;
            enableACME = true;
            locations = {
              "/" = {
                proxyPass = "http://127.0.0.1:8080";
                extraConfig = ''
                  proxy_set_header Host $host;
                  proxy_set_header X-Real-IP $remote_addr;
                  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_set_header X-Forwarded-Proto $scheme;
                '';
              };
            };
          };
          # TODO: WEBDAV and Syncthing
        };
      };

      nextcloud = {
        enable = true;
        configureRedis = true;
        package = pkgs.nextcloud29;
        https = true;
        hostName = "nextcloud.${domain}";
        database.createLocally = true;
        caching = {
          redis = true;
          memcached = true;
          apcu = true;
        };
        config = {
          dbtype = "pgsql";
          adminpassFile = "/etc/nextcloud";
        };
        extraApps = with config.services.nextcloud.package.packages.apps; {
          inherit
            memories
            contacts
            maps
            calendar
            onlyoffice
            mail
            notes
            tasks
            ;
        };
        nginx.recommendedHttpHeaders = true;
        extraAppsEnable = true;
        appstoreEnable = true;
        autoUpdateApps.enable = true;
        phpOptions."opcache.interned_strings_buffer" = "23";
        settings = {
          default_phone_region = "DE";
          overwriteprotocol = "https";
          trusted_domains = [
            # "nextcloud.${domain}"
            "talk.nextcloud.${domain}"
            "files.nextcloud.${domain}"
          ];
          "memories.exiftool" = "/var/lib/nextcloud/store-apps/memories/bin-ext/exiftool/exiftool";
          "memories.vod.ffmpeg" = "${lib.getExe pkgs.ffmpeg-headless}";
          "memories.vod.ffprobe" = "${pkgs.ffmpeg-headless}/bin/ffprobe";
        };
      };

      onlyoffice = {
        enable = true;
        hostname = "office.${domain}";
      };

      znc = {
        enable = true;
        mutable = true; # Overwrite configuration set by ZNC from the web and chat interfaces.
        useLegacyConfig = false; # Turn off services.znc.confOptions and their defaults.
        openFirewall = true; # ZNC uses TCP port 5000 by default.
        config = {
          LoadModule = ["adminlog" "webadmin"]; # Write access logs to ~znc/moddata/adminlog/znc.log.
          Listener.l = {
            Port = 5000;
            SSL = true;
            IPv4 = true;
            IPv6 = true;
          };
          User.hill = {
            Admin = true;
            LoadModule = ["chansaver" "controlpanel" "adminlog" "webadmin"];
            Nick = "hill";
            AltNick = "float3";
            Pass.password = {
              Method = "sha256";
              Hash = "16eb02596e870436a18755684e68c051c87b351cdaea32f3e8cdc2b8b2ae26de";
              Salt = ".,_D+c2OS:MJ/kQLDk+v";
            };

            # Network.freenode = let
            #   createZncServers = servers:
            #     lib.mapAttrs
            #     (_name: cfg: {
            #       Server = "${cfg.ip} +6697";
            #       LoadModule = ["simple_away" "sasl" "keepnick"];
            #       Chan = lib.listToAttrs (
            #         map
            #         (name: lib.nameValuePair name {})
            #         cfg.chan
            #       );
            #     })
            #     servers;
            # in {
            #   Server = "chat.freenode.net +6697";
            #   Chan = {
            #     "#nixos" = {};
            #     "#nixos-wiki" = {};
            #   };
            #   Nick = "hill"; # Supply your password as an argument
            #   LoadModule = ["nickserv yourpassword"]; # <- to the nickserv module here.
            #   JoinDelay = 2; # Avoid joining channels before authenticating.
            # };
          };
        };
      };

      gitlab.enable = true;

      webdav = {
        enable = false;
        settings = {
          address = "0.0.0.0";
          port = 9999;
          scope = "/mnt/volume/webdav";
          modify = true;
          auth = true;
          debug = true;
          users = {
            username = username;
            password = "{env}ENV_PASSWORD";
          };
        };
      };

      syncthing = {
        enable = true;
        settings = {
          options = {
            urAccepted = -1;
          };
          devices = {
            "phone" = {id = "WN2CLGX-32BTWMF-IMOXHJY-MF7RSB7-Z3BJTO2-ITWUQV2-7HXJN6P-436DDQH";};
            "workstation" = {id = "F4SINA6-VIADYQ6-3OH5LFY-YKD4YKC-XPQYLER-QMVGO5P-6VJZ4EW-UAHPIQ3";};
            "laptop" = {id = " GVENSDK-5V75XOG-FAA5JWG-KFNJUF2-EVSETA7-UTIAZOY-RKI6THT-O7BF2AL";};
            "work" = {id = "QYZTFAP-EDSCN2F-J5IVJTA-F757UHG-YX7KPE6-OCVAXKP-QE2XFNA-TEMFPQK";};
            "steamdeck" = {id = "EA3JGYT-VJGJYHE-6IDYE4I-S53P4KO-XKJBQOI-FXN74PU-RIU7ECW-AVXYWQV";};
          };
          folders = {
            "Sync" = {
              id = "default";
              label = "Sync";
              path = "~/Sync";
              devices = [
                "phone"
                "workstation"
                "laptop"
                "work"
                "steamdeck"
              ];
            };
          };
          gui = {
            user = username;
            password = "{env}ENV_PASSWORD";
          };
        };
        guiAddress = "0.0.0.0:8384";
      };
    };

    security = {
      acme = {
        acceptTerms = true;
        defaults = {
          # webroot = "/var/lib/acme/acme-challenge";
          email = "traeumer@${domain}";
        };
        certs = {
          "${domain}".inheritDefaults = true;
          "${config.services.onlyoffice.hostname}".inheritDefaults = true;
          "${config.services.nextcloud.hostName}".inheritDefaults = true;
          "znc.${domain}".inheritDefaults = true;
          "problem.${domain}".inheritDefaults = true;
        };
      };
    };

    systemd = {
      services = {
        nextcloud-cron = {
          path = [pkgs.perl];
        };
      };
      tmpfiles.rules = [
        "d /home/${username}/.config 0755 ${username} users"
        "d /home/${username}/.config/lvim 0755 ${username} users"
        "d /data/webdav 0770 root webdav"
      ];
    };

    system = {
      activationScripts = {
        stidio.text = ''
          ${pkgs.networkmanager}/bin/nmcli device disconnect ens10 || true
          cd /mnt/volume/webapp
          nix-build
          ./start.sh
        '';
      };
      stateVersion = "22.05";
    };

    mailserver = {
      enable = true;
      fqdn = "mail.${domain}";
      domains = ["${domain}"];

      # A list of all login accounts. To create the password hashes, use
      # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
      loginAccounts = {
        "traeumer@${domain}" = {
          hashedPasswordFile = "/home/hill/.config/nixos/hashedmailpass";
          aliases = ["postmaster@${domain}" "hill@${domain}"];
        };
      };

      # Use Let's Encrypt certificates. Note that this needs to set up a stripped
      # down nginx and opens port 80.
      certificateScheme = "acme-nginx";
    };

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };
  }
