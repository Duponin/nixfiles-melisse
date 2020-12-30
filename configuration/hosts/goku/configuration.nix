{ config, pkgs, ... }: {
  imports = [ # Include the results of the hardware scan.
    ../../common
    ./hardware-configuration.nix
    ../../monitoring/prometheus.nix
    ../../monitoring/node-exporter.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Set networking
  networking = {
    firewall = { allowedTCPPorts = [ 22 ]; };
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

  system.stateVersion = "20.09";
}
