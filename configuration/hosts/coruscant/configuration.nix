{ config, pkgs, ... }:
let vm_pub_int = "enp39s0"; # VM Public Interface
in {
  imports = [
    # Imports
    ../../common
    ../../common/hypervisor.nix
    ./hardware-configuration.nix
  ];

  boot.loader.grub = {
    enable = true;
    version = 2;
    mirroredBoots = [
      {
        devices =
          [ "/dev/disk/by-id/nvme-KINGSTON_SA2000M8250G_50026B768425E0C5" ];
        path = "/boot1";
      }
      {
        devices = [
          "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_250GB_S4EUNS0N703315V"
        ];
        path = "/boot2";
      }
    ];
  };

  networking = {
    bridges = {
      br-vm-wan.interfaces = [ vm_pub_int ];
      br-vm-lan.interfaces = [ ];
    };
    firewall = {
      allowedTCPPorts = [ 22 ];
      trustedInterfaces = [ vm_pub_int ];
    };
    hostName = "coruscant";
    interfaces = {
      enp36s0f0 = { useDHCP = false; };
      enp36s0f = { useDHCP = false; };
      enp38s0 = {
        mtu = 1378;
        ipv4 = {
          addresses = [{
            address = "185.233.102.133";
            prefixLength = 26;
          }];
          routes = [{
            address = "0.0.0.0";
            options.mtu = "1378";
            prefixLength = 0;
            via = "185.233.102.190";
          }];
        };
        ipv6 = {
          addresses = [{
            address = "2a0c:e300:12::133";
            prefixLength = 48;
          }];
          routes = [{
            address = "::";
            options.mtu = "1378";
            prefixLength = 0;
            via = "2a0c:e300:12::190";
          }];
        };
      };
      enp39s0 = { useDHCP = false; };
      enp42s0f3u5u3c2.useDHCP = false;
    };
    nameservers = [ "185.233.100.100" "185.233.100.101" "1.1.1.1" ];
    useDHCP = false;
  };

  time.timeZone = "Europe/Paris";

  services.openssh = {
    enable = true;
    openFirewall = true;
  };

  system.stateVersion = "20.09";

}
