{ config, pkgs, ... }: {
  imports = [ # imports
    ../../common
    ../../common/qemu-guest
    ../../common/qemu-guest/uefi.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Set networking
  networking = {
    defaultGateway6 = {
      address = "2a0c:e300:12::190";
      interface = "ens3";
    };
    defaultGateway = {
      address = "185.233.102.190";
      interface = "ens3";
    };
    firewall.checkReversePath = false;
    hostName = "malastare";
    nameservers = [ "185.233.100.100" "185.233.100.101" "1.1.1.1" ];
    interfaces.ens3 = {
      mtu = 1378;
      ipv4 = {
        addresses = [{
          address = "185.233.102.134";
          prefixLength = 26;
        }];
      };
      ipv6 = {
        addresses = [{
          address = "2a0c:e300:12::134";
          prefixLength = 48;
        }];
      };
    };
    interfaces.ens4 = {
      ipv6 = {
        addresses = [
          {
            address = "2a0c:e304:c0fe::1";
            prefixLength = 48;
          }
          {
            address = "2a0c:e304:c0fe:1::1";
            prefixLength = 64;
          }
        ];
      };
    };
  };

  system.stateVersion = "20.09";
}
