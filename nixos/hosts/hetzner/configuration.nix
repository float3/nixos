let
  domain = "traeumerei.dev";
in
  {
    username,
    paths,
    # modulespath,
    config,
    lib,
    inputs,
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
      (modulespath + "/installer/scan/not-detected.nix")
      "${paths.roles}/base.nix"
      "${paths.modules}/builder.nix"
      #inputs.trolley.nixosmodules.webapp

      # (builtins.fetchtarball {
      #   # pick a release version you are interested in and set its hash, e.g.
      #   url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-24.05/nixos-mailserver-nixos-24.05.tar.gz";
      #   # to get the sha256 of the nixos-mailserver tarball, we can use the nix-prefetch-url command:
      #   # release="nixos-23.05"; nix-prefetch-url "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz" --unpack
      #   sha256 = "sha256:0clvw4622mqzk1aqw1qn6shl9pai097q62mq1ibzscnjayhp278b";
      # })
    ];

    boot = {
      loader = {
        grub = {
          efisupport = true;
          efiinstallasremovable = true;
          devices = ["/dev/sdb"];
        };
      };
    };

    users = {
      users = {
        # films = {
        #   isnormaluser = true;
        #   home = "/mnt/volume/films";
        #   extragroups = [];
        #   shell = "/run/current-system/sw/bin/bash";
        #   openssh.authorizedkeys = {
        #     keys = [
        #       "ssh-ed25519 aaaac3nzac1lzdi1nte5aaaaikjl2gzhptrg5cawk8y6orc0a26n6e0qyc760syu3+5h redmage"
        #       "ssh-rsa aaaab3nzac1yc2eaaaadaqabaaacaqcpavb0ihcz0evdizko8bgxndop7qfinavbunsw3k28q7nvyssxqxavyw8onnjt4hhx08jr5m3cagqxmjhhoeru3niazo5ekup3smciyu1o+7mtmgpb4stp+c31op5mfa0ubl6/4e0q7e2zmotl6dwkklfybrdwgsjoelb2dmj8auaxnqliti1bmcbwdqenk4n+awhjjriiukyrzad+o0jq7h5r9vucksmyvrew4oexuy8askppjtn8pyxyp3v5rm/9xsnfhelu+t9y1eyelgfm6tuyfccb1xf7xltlkzjtubfz0hilximksnc38kkltalbhnoahfnduiw70+wi4abqpbga7butlauxsnrkjko3/gnh/hgmo34hapubmw/fkjdijygkc7xug43oit9peppabqysliax11kmzy2ax+k2eunsrny5gtsuu4chtxnsvd7ktzfbgk00g29hnfxtywa9hq3gienp4pidjtqtn1qglrwn0/4ikdm5e5kmzgwluj0c5jj3n7zs3l+g1cel9v8czlb/f8um4oxy+fdky8j7eiybfhbib0x03/u3eole8btoq0hiar4nkhudagz7czmy5uflyvhj9yrbefzdtft5msuwfezcyhubpraydapdqoguh3qp8f4xc0w8wiakn5ryiteole0yn5nqwxixnqztjw== pemamalling@gmail.com"
        #       "ssh-ed25519 aaaac3nzac1lzdi1nte5aaaaidgiroaycja/f9ckeusk+1he1glcelwhdw8vh6kjkkzs div1"
        #       "ssh-ed25519 aaaac3nzac1lzdi1nte5aaaaienanznvkxpkncxr47tf4pbnkilqya/aeoxuj4+qjicx div2"
        #       "ssh-ed25519 aaaac3nzac1lzdi1nte5aaaaik1c1c2rv/iigxafmdp4+uvnzxdlzqxbq5gsf0jspzvh cutestpixelkit@gmail.com"
        #     ];
        #     keyfiles = [
        #       float3-keys.outpath
        #       akaimage-keys.outpath
        #       e00e-keys.outpath
        #       pema99-keys.outpath
        #       nyrox-keys.outpath
        #       stephen-keys.outpath
        #     ];
        #   };
        # };
      };
    };

    environment = {
      shells = [pkgs.fish];
      enableallterminfo = true;

      systempackages = with pkgs; [
        ffmpeg
        nodejs_20
      ];
    };

    programs = {};

    networking = {
      firewall = {
        allowedtcpports = [
          80 # http
          443 # https
          8080 # problem
          22000 # tcp and/or udp for sync traffic
          # config.services.webdav.settings.port # webdav
          # 5000 # znc
          # 6697 # znc
          # 8384 # syncthing gui
        ];
        allowedudpports = [
          22000 # tcp and/or udp for sync traffic
          21027 # udp for discovery
        ];
      };
      networkmanager = {
        unmanaged = ["interface-name:ens10"];
      };
    };

    services = {
      postgresql = {
        enable = true;
        enabletcpip = true;
        settings = {
          unix_socket_directories = "/run/postgresql";
        };
      };
      nginx = {
        recommendedtlssettings = true;
        recommendedoptimisation = true;
        recommendedproxysettings = true;
        recommendedgzipsettings = true;
        enable = true;
        virtualhosts = {
          "${config.services.nextcloud.hostname}" = {
            forcessl = true;
            enableacme = true;
          };
          "${config.services.onlyoffice.hostname}" = {
            forcessl = true;
            enableacme = true;
          };
          "${domain}" = {
            addssl = true;
            enableacme = true;
            # serveraliases = ["www.${domain}"];
            root = "/mnt/volume/${domain}";
          };
          # "znc.${domain}" = {
          #   forcessl = true; # force ssl redirection
          #   enableacme = true; # enable let's encrypt for ssl certificates
          #   locations = {
          #     "/" = {
          #       proxypass = "http://127.0.0.1:5000";
          #       extraconfig = ''
          #         proxy_set_header host $host;
          #         proxy_set_header x-real-ip $remote_addr;
          #         proxy_set_header x-forwarded-for $proxy_add_x_forwarded_for;
          #         proxy_set_header x-forwarded-proto $scheme;
          #       '';
          #     };
          #   };
          # };
          "problem.${domain}" = {
            forcessl = true;
            enableacme = true;
            locations = {
              "/" = {
                proxypass = "http://127.0.0.1:8080";
                extraconfig = ''
                  proxy_set_header host $host;
                  proxy_set_header x-real-ip $remote_addr;
                  proxy_set_header x-forwarded-for $proxy_add_x_forwarded_for;
                  proxy_set_header x-forwarded-proto $scheme;
                '';
              };
            };
          };
          # todo: webdav and syncthing
        };
      };

      nextcloud = {
        enable = true;
        configureredis = true;
        package = pkgs.nextcloud30;
        https = true;
        hostname = "nextcloud.${domain}";
        database.createlocally = true;
        caching = {
          redis = true;
          memcached = true;
          apcu = true;
        };
        config = {
          dbtype = "pgsql";
          adminpassfile = "/etc/nextcloud";
        };
        extraapps = with config.services.nextcloud.package.packages.apps; {
          inherit
            memories
            contacts
            calendar
            onlyoffice
            # mail
            notes
            tasks
            ;
        };
        nginx.recommendedhttpheaders = true;
        extraappsenable = true;
        appstoreenable = true;
        autoupdateapps.enable = true;
        phpoptions."opcache.interned_strings_buffer" = "23";
        settings = {
          default_phone_region = "de";
          overwriteprotocol = "https";
          trusted_domains = [
            # "nextcloud.${domain}"
            "talk.nextcloud.${domain}"
            "files.nextcloud.${domain}"
          ];
          "memories.exiftool" = "/var/lib/nextcloud/store-apps/memories/bin-ext/exiftool/exiftool";
          "memories.vod.ffmpeg" = "${lib.getexe pkgs.ffmpeg-headless}";
          "memories.vod.ffprobe" = "${pkgs.ffmpeg-headless}/bin/ffprobe";
        };
      };

      onlyoffice = {
        enable = true;
        hostname = "office.${domain}";
      };

      # znc = {
      #   enable = true;
      #   mutable = true; # overwrite configuration set by znc from the web and chat interfaces.
      #   uselegacyconfig = false; # turn off services.znc.confoptions and their defaults.
      #   openfirewall = true; # znc uses tcp port 5000 by default.
      #   config = {
      #     loadmodule = ["adminlog" "webadmin"]; # write access logs to ~znc/moddata/adminlog/znc.log.
      #     listener.l = {
      #       port = 5000;
      #       ssl = true;
      #       ipv4 = true;
      #       ipv6 = true;
      #     };
      #     user.hill = {
      #       admin = true;
      #       loadmodule = ["chansaver" "controlpanel" "adminlog" "webadmin"];
      #       nick = "hill";
      #       altnick = "float3";
      #       pass.password = {
      #         method = "sha256";
      #         hash = "16eb02596e870436a18755684e68c051c87b351cdaea32f3e8cdc2b8b2ae26de";
      #         salt = ".,_d+c2os:mj/kqldk+v";
      #       };

      #       # network.freenode = let
      #       #   createzncservers = servers:
      #       #     lib.mapattrs
      #       #     (_name: cfg: {
      #       #       server = "${cfg.ip} +6697";
      #       #       loadmodule = ["simple_away" "sasl" "keepnick"];
      #       #       chan = lib.listtoattrs (
      #       #         map
      #       #         (name: lib.namevaluepair name {})
      #       #         cfg.chan
      #       #       );
      #       #     })
      #       #     servers;
      #       # in {
      #       #   server = "chat.freenode.net +6697";
      #       #   chan = {
      #       #     "#nixos" = {};
      #       #     "#nixos-wiki" = {};
      #       #   };
      #       #   nick = "hill"; # supply your password as an argument
      #       #   loadmodule = ["nickserv yourpassword"]; # <- to the nickserv module here.
      #       #   joindelay = 2; # avoid joining channels before authenticating.
      #       # };
      #     };
      #   };
      # };

      # gitlab.enable = true;

      # webdav = {
      #   enable = false;
      #   settings = {
      #     address = "0.0.0.0";
      #     port = 9999;
      #     scope = "/mnt/volume/webdav";
      #     modify = true;
      #     auth = true;
      #     debug = true;
      #     users = {
      #       username = username;
      #       password = "{env}env_password";
      #     };
      #   };
      # };

      syncthing = {
        enable = true;
        settings = {
          options = {
            uraccepted = -1;
          };
          devices = {
            "phone" = {id = "wn2clgx-32btwmf-imoxhjy-mf7rsb7-z3bjto2-itwuqv2-7hxjn6p-436ddqh";};
            "workstation" = {id = "f4sina6-viadyq6-3oh5lfy-ykd4ykc-xpqyler-qmvgo5p-6vjz4ew-uahpiq3";};
            "laptop" = {id = " gvensdk-5v75xog-faa5jwg-kfnjuf2-evseta7-utiazoy-rki6tht-o7bf2al";};
            "work" = {id = "qyztfap-edscn2f-j5ivjta-f757uhg-yx7kpe6-ocvaxkp-qe2xfna-temfpqk";};
            "steamdeck" = {id = "ea3jgyt-vjgjyhe-6idye4i-s53p4ko-xkjbqoi-fxn74pu-riu7ecw-avxywqv";};
          };
          folders = {
            "sync" = {
              id = "default";
              label = "sync";
              path = "~/sync";
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
            password = "{env}env_password";
          };
        };
        guiaddress = "0.0.0.0:8384";
      };
    };

    security = {
      acme = {
        acceptterms = true;
        defaults = {
          # webroot = "/var/lib/acme/acme-challenge";
          email = "traeumer@${domain}";
        };
        certs = {
          "${domain}".inheritdefaults = true;
          "${config.services.onlyoffice.hostname}".inheritdefaults = true;
          "${config.services.nextcloud.hostname}".inheritdefaults = true;
          # "znc.${domain}".inheritdefaults = true;
          "problem.${domain}".inheritdefaults = true;
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
      activationscripts = {
        stidio.text = ''
          ${pkgs.networkmanager}/bin/nmcli device disconnect ens10 || true
          ${pkgs.coreutils}/bin/echo problem
          ${pkgs.coreutils}/bin/cd /mnt/volume/webapp
          ${pkgs.nix}/bin/nix-build
          ./start.sh
        '';
      };
      stateversion = "22.05";
    };

    # mailserver = {
    #   enable = true;
    #   fqdn = "mail.${domain}";
    #   domains = ["${domain}"];

    #   # a list of all login accounts. to create the password hashes, use
    #   # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
    #   loginaccounts = {
    #     "traeumer@${domain}" = {
    #       hashedpasswordfile = "/home/hill/.config/nixos/hashedmailpass";
    #       aliases = ["postmaster@${domain}" "hill@${domain}"];
    #     };
    #   };

    #   # use let's encrypt certificates. note that this needs to set up a stripped
    #   # down nginx and opens port 80.
    #   certificatescheme = "acme-nginx";
    # };

    # some programs need suid wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enablesshsupport = true;
    # };
  }
