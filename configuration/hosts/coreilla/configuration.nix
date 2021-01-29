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
    defaultGateway = {
      address = "185.233.102.190";
      interface = "ens10";
    };
    hostName = "coreilla";
    useDHCP = false;
    nameservers = [ "2a0c:e300::100" "2a0c:e300::101" ];
    interfaces = {
      ens3 = {
        ipv6 = {
          addresses = [{
            address = "2a0c:e304:c0fe:1::2";
            prefixLength = 64;
          }];
        };
      };
      ens10 = {
        mtu = 1378;
        ipv4 = {
          addresses = [{
            address = "185.233.102.135";
            prefixLength = 26;
          }];
        };
      };
    };
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
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
    virtualHosts."dolibarr.priv.melisse.org" = {
      root = "/var/www/dolibarr.melisse.org/htdocs";
      locations."/" = {
        index = "index.php";
        tryFiles = "$uri $uri/ /index.php?$query_string";
      };
      locations."~ .php$" = {
        extraConfig = ''
          fastcgi_split_path_info ^(.+\.php)(/.+)$;
          fastcgi_pass unix:${config.services.phpfpm.pools.dolibarr.socket};
          fastcgi_index index.php;
          include ${pkgs.nginx}/conf/fastcgi_params;
          include ${pkgs.nginx}/conf/fastcgi.conf;
          allow 2a0c:e304:c0fe:1::/64;
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
            olcRootPW.path = "/run/secrets/ldap_admin";
            olcSuffix = "dc=melisse,dc=org";
            olcAccess = [ "{0}to * by * read break" ];
          };
        };
      };
    };
  };
  age.secrets.ldap_admin.file = ../../../secrets/ldap_admin.age;

  # Dolibarr
  services.postgresql = {
    enable = true;
    authentication = ''
      host all all 127.0.0.1/32 trust
      host all all ::1/128 trust
    '';
    ensureDatabases = [ "dolibarr" ];
    ensureUsers = [{
      name = "dolibarr";
      ensurePermissions = { "DATABASE dolibarr" = "ALL PRIVILEGES"; };
    }];
    # FIXME: user dolibarr has to be dolibarr database's owner
    # sudo -u postgres psql
    # ALTER DATABASE dolibarr owner to dolibarr;
  };
  services.phpfpm.pools.dolibarr = {
    user = "dolibarr";
    group = "dolibarr";
    phpPackage = pkgs.php;
    settings = {
      "listen.owner" = config.services.nginx.user;
      "pm" = "dynamic";
      "pm.max_children" = 32;
      "pm.max_requests" = 500;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 2;
      "pm.max_spare_servers" = 5;
      "php_admin_value[error_log]" = "stderr";
      "php_admin_flag[log_errors]" = true;
      "catch_workers_output" = true;
    };
  };
  users.users."dolibarr" = {
    isSystemUser = true;
    createHome = true;
    home = "/var/www/dolibarr.melisse.org";
    group = "dolibarr";
  };
  users.groups."dolibarr" = { };

  system.stateVersion = "20.09";
}

