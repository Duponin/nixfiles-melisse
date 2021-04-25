{ config, pkgs, ... }:
let
  hostname = "kessel";
  nixpkgs-unstable = fetchTarball
    "https://github.com/nixos/nixpkgs/archive/f217c0ea7c148ddc0103347051555c7c252dcafb.tar.gz";
in {
  imports = [
    (nixpkgs-unstable + "/nixos/modules/services/databases/openldap.nix")
    ../../../modules/monitoring/client.nix
    ../../../modules/nextcloud.nix
    ../../common
    ../../common/secrets.nix
    ../../common/qemu-guest
    ../../common/qemu-guest/uefi.nix
  ];

  # Cf. above, we use openldap service from unstable
  disabledModules = [ "services/databases/openldap.nix" ];

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
      ens9.useDHCP = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  nextcloud = {
    enable = true;
    url = "nextcloud.staging.melisse.org";
    apps = [ "user_ldap" "groupfolders" "groupquota" "calendar" "contacts" ];
    settings = {
      apps.core.shareapi_allow_resharing = "yes";
      apps.core.shareapi_allow_group_sharing = "yes";
      apps.core.shareapi_enabled = "yes";
      apps.core.shareapi_allow_links = "yes";
      apps.core.shareapi_exclude_groups = "no";
      apps.core.shareapi_only_share_with_group_members = "no";
      apps.user_ldap = {
        s01ldap_host = "ldaps://ldap.staging.melisse.org";
        s01ldap_port = "636";
        s01ldap_dn = "uid=nextcloud,ou=applications,dc=melisse,dc=org";
        s01ldap_base_users = "ou=members,dc=melisse,dc=org";
        s01ldap_base_groups = ''
          ou=collectivities,ou=groups,dc=melisse,dc=org
          ou=subscriptiontypes,ou=groups,dc=melisse,dc=org'';
        s01ldap_attributes_for_group_search = ''
          cn
          description'';
        s01ldap_nested_groups = "0";
        s01ldap_group_member_assoc_attribute = "uniqueMember";
        s01ldap_email_attr = "mail";
        s01ldap_group_filter_mode = "1";
        s01ldap_display_name = "cn";
        s01ldap_userfilter_objectclass = "inetOrgPerson";
        s01ldap_userlist_filter = "(|(objectclass=inetOrgPerson))";
        s01ldap_login_filter = "(&(|(objectclass=inetOrgPerson))(uid=%uid))";
        s01ldap_group_filter = "(|(objectclass=groupOfUniqueNames))";
        s01ldap_turn_on_pwd_change = "1";
      };
      apps.groupquota = {
        "quota_free-individual" = "10737418240"; # 10G
        "quota_free-collectivity" = "10737418240"; # 10G
      };
    };
  };

  # LDAP staging
  services.nginx = {
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
        olcTLSCertificateFile =
          "/var/lib/acme/ldap.staging.melisse.org/cert.pem";
        olcTLSCertificateKeyFile =
          "/var/lib/acme/ldap.staging.melisse.org/key.pem";
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
              ''
                {0}to attrs=userPassword
                                by self write
                                by dn.subtree="ou=applications,dc=melisse,dc=org" write
                                by anonymous auth
                                by * none''
              ''
                {1}to dn.subtree="ou=members,dc=melisse,dc=org"
                                by self write
                                by anonymous auth
                                by dn.subtree="ou=applications,dc=melisse,dc=org" read
                                by * none''
              ''
                {2}to dn.subtree="ou=groups,dc=melisse,dc=org"
                                by dn.subtree="ou=applications,dc=melisse,dc=org" read
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

        dn: cn=free-individual,ou=subscriptiontypes,ou=groups,dc=melisse,dc=org
        objectClass: top
        objectClass: groupOfUniqueNames
        cn: free-individual
        uniqueMember: uid=toto,ou=members,dc=melisse,dc=org
        uniqueMember: uid=tata,ou=members,dc=melisse,dc=org
        uniqueMember: uid=tutu,ou=members,dc=melisse,dc=org

        dn: cn=association1,ou=collectivities,ou=groups,dc=melisse,dc=org
        objectClass: top
        objectClass: groupOfUniqueNames
        cn: association1
        description: Une association vraiment pas mal du tout :)
        uniqueMember: uid=toto,ou=members,dc=melisse,dc=org
        uniqueMember: uid=tata,ou=members,dc=melisse,dc=org

        dn: cn=association2,ou=collectivities,ou=groups,dc=melisse,dc=org
        objectClass: top
        objectClass: groupOfUniqueNames
        cn: association2
        description: Une autre association qu'elle est bien!
        uniqueMember: uid=tutu,ou=members,dc=melisse,dc=org

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

        dn: uid=tata,ou=members,dc=melisse,dc=org
        objectClass: top
        objectClass: person
        objectClass: inetOrgPerson
        cn: Tata Tata
        sn: Tata
        givenName: Tata
        uid: tata
        mail: tata@melisse.org
        userPassword:: e0NSWVBUfSQ1JHJvdW5kcz01MDAwMCR0cXJhcU1pRTBibVlhcDkkNnZ2elYxNVZ
         ncEVWTndsU1hHbXZ4aVdDdUFlZlNJVHBDY1RIMml2dXhZMQ==

        dn: uid=tutu,ou=members,dc=melisse,dc=org
        objectClass: top
        objectClass: person
        objectClass: inetOrgPerson
        cn: Tutu Tutu
        sn: Tutu
        givenName: Tutu
        uid: tutu
        mail: tutu@melisse.org
        userPassword:: e0NSWVBUfSQ1JHJvdW5kcz01MDAwMCR6RTk0NU8zNkR4YWZHWGwkQS85bjNDOUg
         vN25PdFo4U252Z1lNN0RsaHFYQTNoWktiTFRrekkuVFRlMA==

      '';
    };
  };
  age.secrets = {
    nextcloud_admin = {
      file = ../../../secrets/nextcloud_admin.age;
      owner = "nextcloud";
      group = "nextcloud";
    };
    ldap_admin = { file = ../../../secrets/ldap_admin.age; };
  };
  system.stateVersion = "20.09";
}
