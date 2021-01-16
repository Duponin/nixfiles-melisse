{ config, pkgs, ... }: {
  imports = [ # Include the results of the hardware scan.
    ../../common
    ./hardware-configuration.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.systemd-boot.enable = true;

  environment.systemPackages = with pkgs; [ borgbackup ];

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Set networking
  networking = {
    defaultGateway6 = {
      address = "2a0c:e300:12::190";
      interface = "ens3";
    };
    firewall = { allowedTCPPorts = [ 22 ]; };
    hostName = "aedu";
    useDHCP = false;
    nameservers = [ "2a0c:e300::100" "2a0c:e300::101" ];
    interfaces.ens3 = {
      mtu = 1378;
      ipv6 = {
        addresses = [{
          address = "2a0c:e300:12::42:2";
          prefixLength = 48;
        }];
      };
    };
  };

  services = { openssh.enable = true; };

  system.stateVersion = "20.09";
}
