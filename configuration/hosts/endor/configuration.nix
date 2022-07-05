{ config, pkgs, ... }:

{
  imports = [
    # Imports
    ../../common
    ../../common/qemu-guest
    ./hardware-configuration.nix
    ./borg.nix
  ];

  boot.loader.grub.device = "/dev/sda";

  networking = {
    defaultGateway = {
      address = "185.233.102.190";
      interface = "ens18";
    };
    defaultGateway6 = {
      address = "2a0c:e300:12::190";
      interface = "ens18";
    };
    hostName = "endor";
    interfaces = {
      ens18 = {
        useDHCP = false;
        mtu = 1378;
        ipv4 = {
          addresses = [{
            address = "185.233.102.157";
            prefixLength = 26;
          }];
        };
        ipv6 = {
          addresses = [{
            address = "2a0c:e300:12::157";
            prefixLength = 48;
          }];
        };
      };
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

  system.stateVersion = "22.05";

}
