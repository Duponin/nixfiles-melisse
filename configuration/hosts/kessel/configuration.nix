{ config, pkgs, ... }:
let hostname = "kessel";
  nixpkgs-unstable = fetchTarball
    "https://github.com/nixos/nixpkgs/archive/f217c0ea7c148ddc0103347051555c7c252dcafb.tar.gz";
in {
  imports = [
    (nixpkgs-unstable + "/nixos/modules/services/databases/openldap.nix")
    ../../../modules/monitoring/client.nix
    ../../common
    ../../common/secrets.nix
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
      overwriteProtocol = "https";
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

  # LDAP staging
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts."ldap.staging.melisse.org" = {
      enableACME = true;
      forceSSL = true;
      locations."./well-known" = {
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
  services.openldap = {
    enable = true;
    urlList = [ "ldaps:///" ];
    group = "nginx"; # FIXME workaround to access to Let's Encrypt certificates
    settings = {
      attrs = {
        olcLogLevel = [ "stats" ];
        olcTLSCACertificateFile =
          "/var/lib/acme/ldap.staging.melisse.org/fullchain.pem";
        olcTLSCertificateFile = "/var/lib/acme/ldap.staging.melisse.org/cert.pem";
        olcTLSCertificateKeyFile = "/var/lib/acme/ldap.staging.melisse.org/key.pem";
        olcPasswordCryptSaltFormat = "$5$rounds=50000$%.16s";
      };
      children = {
        "cn=schema" = {
          includes = [
            "${pkgs.openldap}/etc/schema/core.ldif"
            "${pkgs.openldap}/etc/schema/cosine.ldif"
            "${pkgs.openldap}/etc/schema/inetorgperson.ldif"
            "${pkgs.openldap}/etc/schema/dyngroup.ldif"
            "${pkgs.openldap}/etc/schema/ppolicy.ldif"
          ];
        };
        "olcDatabase={-1}frontend" = {
          attrs = {
            objectClass = [ "olcDatabaseConfig" "olcFrontendConfig" ];
            olcDatabase = "{-1}frontend";
            olcPasswordHash = "{CRYPT}";
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
            olcAccess = [
              ''{0}to dn.subtree="ou=members,dc=melisse,dc=org"
                by self write
                by anonymous auth
                by dn.subtree="ou=applications,dc=melisse,dc=org" read
                by * none''
              ''{1}to attrs=userPassword
                by self write
                by anonymous auth
                by * none''
            ];
          };
        };
        "cn=module{0}" = {
          attrs = {
            objectClass = [ "olcModuleList" ];
            olcModuleLoad = "ppolicy.la";
          };
        };
        "olcOverlay=ppolicy,olcDatabase={1}mdb" = {
          attrs = {
            objectClass = [ "olcConfig" "olcOverlayConfig" "olcPPolicyConfig" ];
            olcOverlay = "ppolicy";
            olcPPolicyDefault = "cn=default,ou=policies,dc=melisse,dc=org";
            olcPPolicyHashCleartext = "TRUE";
          };
        };
      };
    };
    declarativeContents = {
      "dc=melisse,dc=org" = ''
        dn: dc=melisse, dc=org
        objectClass: top
        objectClass: dcObject
        objectClass: organization
        o: melisse.org
        dc: melisse

        dn: ou=groups,dc=melisse,dc=org
        objectClass: top
        objectClass: organizationalUnit
        ou: groups

        dn: ou=members,dc=melisse,dc=org
        objectClass: top
        objectClass: organizationalUnit
        ou: members

        dn: ou=applications,dc=melisse,dc=org
        objectClass: top
        objectClass: organizationalUnit
        ou: applications

        dn: ou=subscriptiontypes,ou=groups,dc=melisse,dc=org
        objectClass: top
        objectClass: organizationalUnit
        ou: subscriptiontypes
        ou: groups

        dn: ou=usertypes,ou=groups,dc=melisse,dc=org
        objectClass: top
        objectClass: organizationalUnit
        ou: usertypes
        ou: groups

        dn: ou=collectivities,ou=groups,dc=melisse,dc=org
        objectClass: top
        objectClass: organizationalUnit
        ou: collectivities
        ou: groups

        dn: uid=nextcloud,ou=applications,dc=melisse,dc=org
        objectClass: top
        objectClass: inetOrgPerson
        uid: nextcloud
        sn: nextcloud
        cn: nextcloud
        userPassword:: e0NSWVBUfSQ1JHJvdW5kcz01MDAwMCR0Z0Z2L3pHWmhxbGVmV3AkTHguSzRnRWx
         HODBja2JLQ0RhdUtFbGdoLmkyNXdzbUlERTZVTGN3ZjB3Lw==

        dn: uid=toto,ou=members,dc=melisse,dc=org
        objectClass: top
        objectClass: person
        objectClass: inetOrgPerson
        cn: Toto Toto
        sn: Toto
        givenName: Toto
        uid: toto
        mail: toto@melisse.org
        userPassword:: e0NSWVBUfSQ1JHJvdW5kcz01MDAwMCRya2pQeGk5RWI5SXIwczUkZnd3Vkl6MW1
         lb0F1L21Rb1NBdmJlcUJJSkNMRGEyWC56VzNhdjhxbWxEMg==
      '';
    };
  };
  age.secrets.ldap_admin.file = ../../../secrets/ldap_admin.age;

  system.stateVersion = "20.09";
}
