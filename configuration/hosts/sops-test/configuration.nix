{ config, pkgs, ... }: {
  imports = [ # Include the results of the hardware scan.
    ../../common
    ./hardware-configuration.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/vda";

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Set networking
  networking = {
    firewall = { allowedTCPPorts = [ 22 ]; };
    hostName = "sops-test";
    useDHCP = false;
    nameservers = [ "2a0c:e300::100" "2a0c:e300::101" ];
    interfaces.ens3 = {
      ipv4 = {
        addresses = [{
          address = "2a0c:e300:12::42:3";
          prefixLength = 26;
        }];
        routes = [{
          address = "0.0.0.0";
          prefixLength = 0;
          via = "2a0c:e300:12::190";
        }];
      };
    };
    interfaces.ens4.useDHCP = false;
  };

  services = { openssh.enable = true; };

  system.stateVersion = "20.09";
}
