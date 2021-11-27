{ config, pkgs, ... }:
let
  vm_pub_int = "enp39s0"; # VM Public Interface
  hostname = "coruscant";
in {
  imports = [
    # Imports
    ../../common
    ./hardware-configuration.nix
    ./dhcp.nix
    ../../common/nginx.nix
    ./router.nix
    ./borg.nix
    ./docker.nix
    ./wireguard.nix
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

  fileSystems."/var/lib/libvirt/images" = {
    device = "/dev/disk/by-uuid/66978328-978a-4943-b832-88201482756f";
    fsType = "ext4";
  };

  fileSystems."/var/lib/docker" = {
    device = "/dev/disk/by-uuid/03e8d0f1-cbf3-4738-a0fa-4d1110a8110f";
    fsType = "ext4";
  };

  monitoring.client.enable = true;
  monitoring.client.host = hostname;

  networking = {
    defaultGateway = {
      address = "185.233.102.190";
      interface = "enp38s0";
    };
    defaultGateway6 = {
      address = "2a0c:e300:12::190";
      interface = "enp38s0";
    };
    bridges = {
      br-vm-wan.interfaces = [ vm_pub_int ];
      br-vm-lan.interfaces = [ ];
      br-vm-nat.interfaces = [ ];
    };
    firewall.checkReversePath = false;
    firewall.trustedInterfaces = [ vm_pub_int ];
    hostName = "coruscant";
    interfaces = {
      br-vm-lan = {
        useDHCP = false;
        ipv6 = {
          addresses = [
            {
              address = "2a0c:e304:c0fe::1";
              prefixLength = 64;
            }
            {
              address = "2a0c:e304:c0fe:1::1";
              prefixLength = 64;
            }
          ];
        };
      };
      br-vm-nat = {
        useDHCP = false;
        ipv4 = {
          addresses = [{
            address = "10.1.0.1";
            prefixLength = 16;
          }];
        };
      };
      br-vm-wan = {
        useDHCP = false;
        # FIXME MTU is not applied, it has to be done by hand
        mtu = 1378;
        ipv4 = {
          addresses = [{ # Used for NAT-ing purpose
            address = "185.233.102.134";
            prefixLength = 26;
          }];
        };
        ipv6 = {
          addresses = [{
            # Needed for our /48 block
            # The router is sending packets to /48 to this IP
            address = "2a0c:e300:12::134";
            prefixLength = 48;
          }];
        };
      };
      enp36s0f0.useDHCP = false;
      enp36s0f.useDHCP = false;
      enp38s0 = {
        useDHCP = false;
        # FIXME MTU is not applied, it has to be done by hand
        mtu = 1378;
        ipv4 = {
          addresses = [{
            address = "185.233.102.133";
            prefixLength = 26;
          }];
        };
        ipv6 = {
          addresses = [{
            address = "2a0c:e300:12::133";
            prefixLength = 48;
          }];
        };
      };
      enp39s0.useDHCP = false;
      enp42s0f3u5u3c2.useDHCP = false;
    };
    nameservers = [
      "2a0c:e300::100"
      "2a0c:e300::101"
      "185.233.100.100"
      "185.233.100.101"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
      "1.0.0.1"
      "1.1.1.1"
    ];
    useDHCP = false;
  };

  system.stateVersion = "20.09";

}
