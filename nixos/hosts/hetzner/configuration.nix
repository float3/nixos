{
  username,
  modulesPath,
  config,
  lib,
  pkgs,
  hill-keys,
  redmage-keys,
  divayth-keys,
  pema-keys,
  mark-keys,
  stephen-keys,
  paths,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
    (modulesPath + "/installer/scan/not-detected.nix")
    "${paths.modulesPath}/shared.nix"
    "${paths.modulesPath}/builder.nix"
  ];

  boot = {
    loader = {
      grub = {
        efiSupport = true;
        efiInstallAsRemovable = true;
      };
    };
  };

  users = {
    groups = {
      filmusers = {
        gid = 1000;
        members = [
          "hill"
          "redmage"
          "divayth"
          "nyrox"
          "pema"
          "stephen"
          "kit"
        ];
      };
    };
    users = {
      root = {
        isNormalUser = false;
        home = "/root";
        extraGroups = [
          "wheel"
          "filmusers"
        ];
        openssh.authorizedKeys = {
          keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG04EoKVJnby/inn+vt7Jh0X9Yd22tIrC5wnE6Xf2jFh pchill"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEdafTHCg+N8xdx68Ek9DwlY1spwlwdVhZlrafOdXuUL pcroot"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP0Wlnrq0zb0M6VLrQ4f6n6wB6NP5/T8RdV9qpWcr3OR laptophill"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/mAHdDcDGHsV7Ub90v0bA+HV3DJIM/XIX7R+IbSOfN laptoproot"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDgpZtquYpnhCxMg7piBD3Y+exV0lbyMPEMDS25Fb5MP phone"
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC+mxF9W8N/sXSCZnFIgJzkaj9inmD2tMsWRU+PXyJ0MC51/emf1GJzagSycUk+P6z1A04fGm8cOHOgAQL6AdO/5AzT7naELOmd4s6eNoAPWM7nKVfJjGWgdfsFoHRzAFoQJbtSmTTNbgqJxXSHyLEauS1vIRMurmF4oPCDBAMRj7mOVdfs3y5lCwYXxLzOWFbtjOZeHpdHt3nIHQgcO9iHPLcmtKQIP0IW7+J9FjDcc8zv6IWNo3F5q2hjHy64IsgJ7uF1kFstr9I+b7PDZv3rbsp0GBJlB0CKZCxm2JZ9JKNlVGdHp+fdA+xYDXRGlLb5CU/XxMuQmVXqp5ND5qtemKSwJx8eCMqSaUqbJnkUL3VcvJgaEvNHYXYyXCN62IDlNqVyPNhZegJstW7WBJjyNi9RM3waTr51MISNy9KnPe57QQWJJAhMcVPFPET/BOWWHs4sHwqb4CngVYDj0IHnVNj/yuuDkbGhLAcpO2eBT5GxzVrzvwiceADyRoSwpp0= groupinfra\davidluca.weil@DE-L088076"
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC1byF77iQy3fK8DSgCGdO1Oo5BDiMdIQJr1Mix5olHyEm7DxkcJ4Qj26gJnWJvFhA/20co2a2pghuPipXaWOPCcYgleuEThJPcow2zQp8pjm+hm86Ooz8bj2DjBMEqxQU9lsKbrpradQm3rho9JEM8bwc9BR8ilyRP9ecSfmuRYoDyUWNcxpEXcviqMAbvCxz0MhS+ZV+3YtSHDRDBGvDU45VTa7il8RpBvEvcnkRaXWjf9dqqCAWvELI5mZND6xMPxZ2ljXI5V8jVEs7q1iTLH8BsdkkW54Gi54Vyeuh/3Efx2sdRBPdL410hEvjUyZiSo3fSXNWbstMeAQ/0ph7mu+CVvf4YTMc+Tojgd3eGS3PsZbrokDbYNRN32jFV+3480ZjXWcK6XtBuiQyFywivmm73LZayFsCDkxp8sBU5I4L70Z8r9KpC2L7zOgxPfdP3HmoVA5/5PDeHexg0gfpfvOvJ5L+fsQgtgTryqLRFwbUG6Ob3zPIAd2/8BGCQhy8="
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAhFNsOJOIN3kAhV5smuLSqwaXeQt0CvF18wM27gt9H5 jaewon"
          ];
          keyFiles = [hill-keys.outPath];
        };
      };

      redmage = {
        isNormalUser = true;
        home = "/home/redmage";
        extraGroups = [
          "filmusers"
        ];
        shell = "/run/current-system/sw/bin/bash";
        openssh.authorizedKeys = {
          keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKJL2GzHptrg5cAWk8y6ORC0A26N6e0qYc760SYU3+5h"
          ];
          keyFiles = [redmage-keys.outPath];
        };
      };

      divayth = {
        isNormalUser = true;
        home = "/home/divayth";
        extraGroups = [
          "filmusers"
        ];
        shell = "/run/current-system/sw/bin/bash";
        openssh.authorizedKeys = {
          keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDgiROaYCJa/f9CKEUsK+1HE1GLcElWhdW8VH6KJKkZS div1"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEnaNznvKxpKNcxR47TF4PBnKilQyA/aEOxuj4+QJIcX div2"
          ];
          keyFiles = [divayth-keys.outPath];
        };
      };

      nyrox = {
        isNormalUser = true;
        home = "/home/nyrox";
        extraGroups = [
          "filmusers"
        ];
        shell = "/run/current-system/sw/bin/bash";
        openssh.authorizedKeys = {
          keys = [];
          keyFiles = [mark-keys.outPath];
        };
      };

      pema = {
        isNormalUser = true;
        home = "/home/pema";
        extraGroups = [
          "filmusers"
        ];
        shell = "/run/current-system/sw/bin/bash";
        openssh.authorizedKeys = {
          keys = [];
          keyFiles = [pema-keys.outPath];
        };
      };

      stephen = {
        isNormalUser = true;
        home = "/home/stephen";
        extraGroups = [
          "filmusers"
        ];
        shell = "/run/current-system/sw/bin/bash";
        openssh.authorizedKeys = {
          keys = [];
          keyFiles = [stephen-keys.outPath];
        };
      };

      kit = {
        isNormalUser = true;
        home = "/home/kit";
        extraGroups = [
          "filmusers"
        ];
        shell = "/run/current-system/sw/bin/bash";
        openssh.authorizedKeys = {
          keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK1C1c2Rv/iIgXAFMdp4+UVnZxDLzQXbQ5Gsf0jSPzvh cutestpixelkit@gmail.com"
          ];
          keyFiles = [];
        };
      };
    };
  };

  environment = {
    shells = [pkgs.fish];
    enableAllTerminfo = true;

    systemPackages = with pkgs; [
    ];
  };

  programs = {};

  networking = {
    firewall.allowedTCPPorts = [80 443 8080 config.services.webdav.settings.port];
  };
  services = {
    postgresql = {
      enable = true;
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
        "traeumerei.dev" = {
          addSSL = true;
          enableACME = true;
          # serverAliases = ["www.traeumerei.dev"];
          root = "/mnt/volume/traeumerei.dev";
        };
      };
    };
    nextcloud = {
      enable = true;
      configureRedis = true;
      package = pkgs.nextcloud29;
      https = true;
      hostName = "nextcloud.traeumerei.dev";
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
          ;
      };
      nginx.recommendedHttpHeaders = true;
      extraAppsEnable = true;
      appstoreEnable = true;
      autoUpdateApps.enable = true;
      settings = {
        overwriteprotocol = "https";
        trusted_domains = [
          # "nextcloud.traeumerei.dev"
          "talk.nextcloud.traeumerei.dev"
          "files.nextcloud.traeumerei.dev"
        ];
      };
    };
    webdav = {
      enable = true;
      settings = {
        address = "0.0.0.0";
        port = 9999;
        scope = "/mnt/volume/webdav";
        modify = true;
        auth = true;
        debug = true;
        users = {
          username = "hill";
          password = "{env}WEBDAV_PASSWORD";
        };
      };
    };
  };

  security = {
    acme = {
      acceptTerms = true;
      defaults = {
        # webroot = "/var/lib/acme/acme-challenge";
        email = "traeumer@traeumerei.dev";
      };
      certs = {
        "traeumerei.dev".inheritDefaults = true;
        "${config.services.nextcloud.hostName}".inheritDefaults = true;
      };
    };
  };

  systemd = {
    services = {
      nextcloud-add-user = {
        path = [config.services.nextcloud.occ];
        script = ''
          export OC_PASS="$(cat /run/secrets/nextcloud/tetoPassword)"
          nextcloud-occ user:add --password-from-env teto
          ${config.services.nextcloud.occ}/bin/nextcloud-occ user:setting ${username} settings email "traeumer@traeumerei.dev"
        '';
        # ${config.services.nextcloud.occ}/bin/nextcloud-occ user:add --password-from-env user2
        # ${config.services.nextcloud.occ}/bin/nextcloud-occ user:setting user2 settings email "user2@localhost"
        # ${config.services.nextcloud.occ}/bin/nextcloud-occ user:setting admin settings email "admin@localhost"
        serviceConfig = {
          Type = "oneshot";
          User = "nextcloud";
        };
        # DONT run it automatically
        # after = [ "nextcloud-setup.service" ];

        # see https://discourse.nixos.org/t/disable-a-systemd-service-while-having-it-in-nixoss-conf/12732
        wantedBy = lib.mkForce [];
        # "multi-user.target"
        # ];
      };
      disable-network-device = {
        script = ''${pkgs.networkmanager}/bin/nmcli device disconnect ens10'';
        wantedBy = ["multi-user.target"];
      };
    };
    tmpfiles.rules = [
      "d /home/${username}/.config 0755 ${username} users"
      "d /home/${username}/.config/lvim 0755 ${username} users"
      "d /data/webdav 0770 root webdav"
    ];
  };

  system = {
    activationScripts.groupFolderAccess = ''
      chown -R :filmusers /mnt/volume/films
      chmod -R 770 /mnt/volume/films
    '';

    stateVersion = "22.05";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
}
