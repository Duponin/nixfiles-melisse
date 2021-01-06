{ config, pkgs, ... }: {
  imports = [ # Include the results of the hardware scan.
    ../../common
    ./hardware-configuration.nix
    ../../monitoring/prometheus.nix
    ../../monitoring/node-exporter.nix
    ../../monitoring/netdata.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Set networking
  networking = {
    firewall = { allowedTCPPorts = [ 22 80 443 ]; };
    hostName = "goku";
    useDHCP = false;
    nameservers = [ "185.233.100.100" "185.233.100.101" "1.1.1.1" ];
    interfaces.ens18 = {
      ipv4 = {
        addresses = [{
          address = "10.0.50.10";
          prefixLength = 24;
        }];
        routes = [{
          address = "0.0.0.0";
          prefixLength = 0;
          via = "10.0.50.1";
        }];
      };
    };
  };

  services = { openssh.enable = true; };

  # Matrix / postgresql config
  # IF INITIAL SCRIPT SEEMS TO BE NOT EXECUTED...
  # FOUND ON https://nixos.wiki/wiki/PostgreSQL
  #
  #   $ sudo -u postgres psql -f "/nix/store/<hash-out-path>-synapse-init.sql" --port=5432 -d postgres
  services.postgresql = {
    enable = true;
    initialScript = pkgs.writeText "synapse-init.sql" ''
      CREATE ROLE "matrix-synapse";
      CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
        TEMPLATE template0
        LC_COLLATE = "C"
        LC_CTYPE = "C";
      '';
  };

  services.matrix-synapse = {
    enable = true;
    server_name = "matrix-test.melisse.org";
    listeners = [ {
      port = 8448;
      bind_address = "";
      type = "http";
      tls = false;
      x_forwarded = true;
      resources = [ {
        names = [ "client" ];
        compress = false;
      } ];
    } ];
  };

  system.stateVersion = "20.09";
}
