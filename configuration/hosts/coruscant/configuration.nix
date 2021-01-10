{ config, pkgs, ... }:

{
  imports = [
    # Imports
    ../../common
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
    firewall.allowedTCPPorts = [ 22 ];
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
            prefixLength = 0;
            via = "185.233.102.190";
          }];
        };
      };
      enp39s0 = { useDHCP = false; };
      enp42s0f3u5u3c2.useDHCP = false;
    };
    useDHCP = false;
  };

  time.timeZone = "Europe/Paris";

  services.openssh.enable = true;

  system.stateVersion = "20.09";

}
