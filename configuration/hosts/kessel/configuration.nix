{ config, pkgs, ... }:
let hostname = "kessel";
in {
  imports = [
    ../../../modules/monitoring/client.nix
    ../../common
    ../../common/secrets.nix
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

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  services.nextcloud = {
    https = true;
    enable = true;
    package = pkgs.nextcloud20;
    hostName = "nextcloud.staging.melisse.org";
    config = {
      dbname = "nextcloud";
      dbport = 5432;
      dbtype = "pgsql";
      adminpassFile = "/run/secrets/nextcloud_admin";
      overWriteProtocol = "https";
    };
  };
  age.secrets.nextcloud_admin.file = ../../../secrets/nextcloud_admin.age;
  services.postgresql = {
    enable = true;
    authentication = ''
      host all all 127.0.0.1/32 trust
      host all all ::1/128      trust
    '';
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [{
      name = "nextcloud";
      ensurePermissions = { "DATABASE nextcloud" = "ALL PRIVILEGES"; };
    }];
    # FIXME: user nextcloud has to be nextcloud database's owner
    # sudo -u postgres psql
    # ALTER DATABASE nextcloud owner to nextcloud;
  };

  system.stateVersion = "20.09";
}
