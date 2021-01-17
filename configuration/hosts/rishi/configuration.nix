{ config, pkgs, ... }: {
  imports = [ # imports
    ../../common/qemu-guest
    ../../common/qemu-guest/uefi.nix
  ];

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  networking = {
    defaultGateway6 = {
      address = "2a0c:e304:c0fe:1::1";
      interface = "ens3";
    };
    hostName = "rishi";
    nameservers = [ "2a0c:e300::100" "2a0c:e300::101" ];
    interfaces = {
      ens3 = {
        mtu = 1500;
        ipv6 = {
          addresses = [{
            address = "2a0c:e304:c0fe:1::3";
            prefixLength = 48;
          }];
        };
      };
    };
  };

  system.stateVersion = "20.09";
}
