{ config, pkgs, ... }:
let hostname = "sullust";
in {
  imports = [ # imports
    ../../../modules/monitoring/client.nix
    ../../common
    ../../common/qemu-guest
    ../../common/qemu-guest/uefi.nix
  ];

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  monitoring.client.enable = true;
  monitoring.client.host = hostname;

  networking = {
    defaultGateway6 = {
      address = "2a0c:e304:c0fe:1::1";
      interface = "ens3";
    };
    defaultGateway = {
      address = "185.233.102.190";
      interface = "ens4";
    };
    hostName = hostname;
    nameservers = [ "2a0c:e300::100" "2a0c:e300::101" ];
    interfaces = {
      ens3 = {
        mtu = 1500;
        ipv6 = {
          addresses = [{
            address = "2a0c:e304:c0fe:1::5";
            prefixLength = 64;
          }];
        };
      };
      ens4 = {
        mtu = 1378;
        ipv4 = {
          addresses = [{
            address = "185.233.102.136";
            prefixLength = 26;
          }];
        };
      };
    };
  };

  system.stateVersion = "20.09";
}
