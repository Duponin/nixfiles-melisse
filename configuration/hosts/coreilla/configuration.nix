{ config, pkgs, ... }: {
  imports = [ # Include the results of the hardware scan.
    ../../common
    ../../common/qemu-guest
    ../../common/qemu-guest/uefi.nix
  ];

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Set networking
  networking = {
    defaultGateway6 = {
      address = "2a0c:e304:c0fe:1::1";
      interface = "ens3";
    };
    hostName = "coreilla";
    useDHCP = false;
    nameservers = [ "2a0c:e300::100" "2a0c:e300::101" ];
    interfaces = {
      ens3 = {
        mtu = 1500;
        ipv6 = {
          addresses = [{
            address = "2a0c:e304:c0fe:1::2";
            prefixLength = 48;
          }];
        };
      };
    };
  };

  system.stateVersion = "20.09";
}
