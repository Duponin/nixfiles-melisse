{ config, pkgs, ... }:
let hostname = "aedu";
in {
  imports = [ # imports
    ../../../modules/monitoring/client.nix
    ../../common
    ../../common/qemu-guest
    ../../common/qemu-guest/uefi.nix
  ];

  environment.systemPackages = with pkgs; [ borgbackup ];

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
    hostName = "aedu";
    useDHCP = false;
    nameservers = [ "2a0c:e300::100" "2a0c:e300::101" ];
    interfaces.ens3 = {
      mtu = 1500;
      ipv6 = {
        addresses = [{
          address = "2a0c:e304:c0fe:1::4";
          prefixLength = 48;
        }];
      };
    };
  };

  services.borgbackup.repos = {
    melisse_malastare = {
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE95SUeLCzTzcHUK7VPDEgXEFdpgHlr3efgTdDSU3m0f root@malastare"
      ];
      path = "/var/lib/backups/melisse/malastare";
    };
  };

  system.stateVersion = "20.09";
}
