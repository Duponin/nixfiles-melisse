{ config, pkgs, ... }:
let
  vm_pub_int = "enp39s0"; # VM Public Interface
  hostname = "coruscant";
in {
  imports = [
    # Imports
    ../../../modules/monitoring/client.nix
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

  fileSystems."/var/lib/libvirt/images" = {
    device = "/dev/disk/by-uuid/66978328-978a-4943-b832-88201482756f";
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
    };
    firewall.trustedInterfaces = [ vm_pub_int ];
    hostName = "coruscant";
    interfaces = {
      enp36s0f0 = { useDHCP = false; };
      enp36s0f = { useDHCP = false; };
      enp38s0 = {
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
          routes = [{
            address = "2a0c:e304:c0fe::";
            prefixLength = 48;
            via = "2a0c:e300:12::134";
          }];
        };
      };
      enp39s0 = { useDHCP = false; };
      enp42s0f3u5u3c2.useDHCP = false;
    };
    nameservers = [
      "185.233.100.100"
      "185.233.100.101"
      "1.1.1.1"
      "2a0c:e300::100"
      "2a0c:e300::101"
    ];
    useDHCP = false;
  };

  time.timeZone = "Europe/Paris";

  system.stateVersion = "20.09";

}
