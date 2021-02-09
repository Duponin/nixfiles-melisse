{ config, pkgs, ... }:
let hostname = "sullust";
in {
  imports = [ # imports
    ../../../modules/backup/client.nix
    ../../../modules/monitoring/client.nix
    ../../../modules/nextcloud.nix
    ../../common
    ../../common/secrets.nix
    ../../common/qemu-guest
    ../../common/qemu-guest/uefi.nix
  ];

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  monitoring.client.enable = true;
  monitoring.client.host = hostname;

  networking = {
    defaultGateway6 = {
      address = "2a0c:e304:c0fe:1::1";
      interface = "ens3";
    };
    defaultGateway = {
      address = "185.233.102.190";
      interface = "ens4";
    };
    hostName = hostname;
    nameservers = [ "2a0c:e300::100" "2a0c:e300::101" ];
    interfaces = {
      ens3 = {
        mtu = 1500;
        ipv6 = {
          addresses = [{
            address = "2a0c:e304:c0fe:1::5";
            prefixLength = 64;
          }];
        };
      };
      ens4 = {
        mtu = 1378;
        ipv4 = {
          addresses = [{
            address = "185.233.102.136";
            prefixLength = 26;
          }];
        };
      };
    };
  };

  nextcloud = {
    enable = true;
    url = "cloud.melisse.org";
    apps = [ "user_ldap" "groupfolders" "groupquota" "calendar" "contacts" ];
    settings = {
      apps.core.shareapi_allow_resharing = "yes";
      apps.core.shareapi_allow_group_sharing = "yes";
      apps.core.shareapi_enabled = "yes";
      apps.core.shareapi_allow_links = "yes";
      apps.core.shareapi_exclude_groups = "no";
      apps.core.shareapi_only_share_with_group_members = "no";
      apps.user_ldap = {
        s01ldap_host = "ldaps://ldap.melisse.org";
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
      };
      apps.groupquota = {
        "quota_free-individual" = "10737418240"; # 10G
        "quota_free-collectivity" = "10737418240"; # 10G
      };
    };
  };

  backup.client = {
    enable = true;
    host = hostname;
    paths = [ "/var/lib/nextcloud" "/var/backup/postgresql" ];
  };

  age.secrets = {
    nextcloud_admin = {
      file = ../../../secrets/nextcloud_admin.age;
      owner = "nextcloud";
      group = "nextcloud";
    };
    backup_passwd = { file = ../../../secrets/sullust_backup_passwd.age; };
  };

  system.stateVersion = "20.09";
}
