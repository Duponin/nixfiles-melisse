{ config, pkgs, ... }:
let hostname = "anoat";
in {
  imports = [
    ../../../modules/monitoring/client.nix
    ../../common
    ../../common/qemu-guest
    ../../common/qemu-guest/uefi.nix
  ];

  monitoring.client.enable = true;
  monitoring.client.host = hostname;

  networking = {
    defaultGateway6 = {
      address = "2a0c:e304:c0fe:1::1";
      interface = "ens3";
    };
    hostName = hostname;
    nameservers = [ "2a0c:e300::100" "2a0c:e300::101" ];
    interfaces = {
      ens3 = {
        mtu = 1500;
        ipv6 = {
          addresses = [{
            address = "2a0c:e304:c0fe:1::6";
            prefixLength = 64;
          }];
        };
      };
      ens4.useDHCP = true;
    };
  };

  system.stateVersion = "20.09";
}
