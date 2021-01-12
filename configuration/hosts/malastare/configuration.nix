{ config, pkgs, ... }: {
  imports = [ # Include the results of the hardware scan.
    ../../common
    ./hardware-configuration.nix
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
    hostName = "melastare";
    useDHCP = false;
    nameservers = [ "185.233.100.100" "185.233.100.101" "1.1.1.1" ];
    interfaces.ens18 = {
      ipv4 = {
        addresses = [{
          address = "185.233.102.134";
          prefixLength = 26;
        }];
        routes = [{
          address = "0.0.0.0";
          prefixLength = 0;
          via = "185.233.102.190";
        }];
      };
    };
  };

  services = { openssh.enable = true; };

  system.stateVersion = "20.09";
}
