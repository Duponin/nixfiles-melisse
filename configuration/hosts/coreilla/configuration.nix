{ config, pkgs, ... }:
let
  hostname = "coreilla";
  nixpkgs-unstable = fetchTarball
    "https://github.com/nixos/nixpkgs/archive/f217c0ea7c148ddc0103347051555c7c252dcafb.tar.gz";
in {
  imports = [
    (nixpkgs-unstable + "/nixos/modules/services/databases/openldap.nix")
    ../../../modules/monitoring/client.nix
    ../../common
    ../../common/qemu-guest
    ../../common/qemu-guest/uefi.nix
  ];

  # Cf. above, we use openldap service from unstable
  disabledModules = [ "services/databases/openldap.nix" ];

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
      ens9.useDHCP = true; # NAT network to have IPv4
    };
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    virtualHosts."ldap.melisse.org" = {
      enableACME = true;
      forceSSL = true;
      locations."/.well-known" = {
        extraConfig = ''
          proxy_ssl_server_name on;
        '';
      };
      locations."/" = {
        extraConfig = ''
          proxy_ssl_server_name on;
          deny all;
        '';
      };
    };
  };
  networking.firewall.allowedTCPPorts = [ 636 ];
  services.openldap = {
    enable = true;
    urlList = [ "ldaps:///" ];
    group = "nginx"; # FIXME workaround to access to Let's Encrypt certificates
    settings = {
      attrs = {
        olcLogLevel = [ "stats" ];
        olcTLSCACertificateFile =
          "/var/lib/acme/ldap.melisse.org/fullchain.pem";
        olcTLSCertificateFile = "/var/lib/acme/ldap.melisse.org/cert.pem";
        olcTLSCertificateKeyFile = "/var/lib/acme/ldap.melisse.org/key.pem";
      };
      children = {
        "cn=schema" = {
          includes = [
            "${pkgs.openldap}/etc/schema/core.ldif"
            "${pkgs.openldap}/etc/schema/cosine.ldif"
            "${pkgs.openldap}/etc/schema/inetorgperson.ldif"
            "${pkgs.openldap}/etc/schema/dyngroup.ldif"
          ];
        };
        "olcDatabase={-1}frontend" = {
          attrs = {
            objectClass = "olcDatabaseConfig";
            olcDatabase = "{-1}frontend";
            olcAccess = [
              "{0}to * by dn.exact=uidNumber=0+gidNumber=0,cn=peercred,cn=external,cn=auth manage stop by * none stop"
            ];
          };
        };
        "olcDatabase={0}config" = {
          attrs = {
            objectClass = "olcDatabaseConfig";
            olcDatabase = "{0}config";
            olcAccess = [ "{0}to * by * none break" ];
          };
        };
        "olcDatabase={1}mdb" = {
          attrs = {
            objectClass = [ "olcDatabaseConfig" "olcMdbConfig" ];
            olcDatabase = "{1}mdb";
            olcDbDirectory = "/var/db/ldap";
            olcDbIndex = [
              "objectClass eq"
              "cn pres,eq"
              "uid pres,eq"
              "sn pres,eq,subany"
            ];
            olcRootDN = "cn=admin,dc=melisse,dc=org";
            olcSuffix = "dc=melisse,dc=org";
            olcAccess = [ "{0}to * by * read break" ];
          };
        };
      };
    };
  };

  system.stateVersion = "20.09";
}
