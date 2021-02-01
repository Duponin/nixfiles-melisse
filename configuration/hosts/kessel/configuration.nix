{ config, pkgs, ... }:
let hostname = "kessel";
in {
  imports = [
    ../../../modules/monitoring/client.nix
    ../../common
    ../../common/qemu-guest
    ../../common/qemu-guest/uefi.nix
  ];

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  monitoring.client.enable = true;
  monitoring.client.host = hostname;

  # Set networking
  networking = {
    defaultGateway6 = {
      address = "2a0c:e304:c0fe:1::1";
      interface = "ens3";
    };
    hostName = hostname;
    useDHCP = false;
    nameservers = [ "2a0c:e300::100" "2a0c:e300::101" ];
    interfaces = {
      ens3 = {
        ipv6 = {
          addresses = [{
            address = "2a0c:e304:c0fe:1::7";
            prefixLength = 64;
          }];
        };
      };
    };
  };

  system.stateVersion = "20.09";
}
