{ config, pkgs, ... }:
let hostname = "florrum";
in {
  imports = [ # imports
    ../../../modules/monitoring/client.nix
    ../../common
    ../../common/secrets.nix
    ./hardware-configuration.nix
  ];
  age.secrets.wireguard_privatekey.file =
    ../../../secrets/florrum_wireguard_privatekey.age;

  monitoring.client.enable = true;
  monitoring.client.host = hostname;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = hostname;
    useDHCP = false;
    interfaces.enp2s0.useDHCP = true;
    wireguard.interfaces = {
      wg0 = {
        listenPort = 51820;
        privateKeyFile = "/run/secrets/wireguard_privatekey";
        ips = [ "2a0c:e304:c0fe:20::12/64" ];

        peers = [{
          publicKey = "ldEQJx37V3lA20QUvDbdEouP7SqHunOXink+pN0pynQ=";
          allowedIPs = [ "::/0" ];
          endpoint = "coruscant.melisse.org:51820";
          persistentKeepalive = 25;
        }];
      };
    };
    firewall.allowedUDPPorts = [ 51820 ];
  };

  services.borgbackup.repos = {
    melisse_sullust = {
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGj4Gqib56G8kKgOUxcZeM4YxEhos41v6Ztrf2/6gs+M root@sullust"
      ];
      path = "/var/lib/backups/melisse/sullust";
    };
    melisse_coreilla = {
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDiqPblq1nqIQtP9YHkVMD0pwKsyL2yeK6KMdeQYoVrD root@coreilla"
      ];
      path = "/var/lib/backups/melisse/coreilla";
    };
  };

  system.stateVersion = "20.09";
}