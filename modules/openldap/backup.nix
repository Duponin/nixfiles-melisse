{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.openldapBackup;

  openldapBackupService = dumpCmd:
    {
      enable = true;
      description = "Backup of openldap database";
      requires = [ "openldap.service" ];
      script = ''
        umask 0077 # ensure backup is only readable by openldap user

        if [ -e ${cfg.location}/openldap.ldif.gz ]; then
          ${pkgs.coreutils}/bin/mv ${cfg.location}/openldap.ldif.gz ${cfg.location}/openldap.prev.ldif.gz
        fi

        ${dumpCmd} | \
          ${pkgs.gzip}/bin/gzip -c > ${cfg.location}/openldap.ldif.gz
      '';

      serviceConfig = {
        Type = "oneshot";
        User = "openldap";
      };

      startAt = cfg.startAt;
    };

in {

  options = {
    services.openldapBackup = {
      enable = mkEnableOption "OpenLDAP ldif dumps";

      startAt = mkOption {
        default = "*-*-* 01:15:00";
        description = ''
          This option defines (see <literal>systemd.time</literal> for format) when the
          databases should be dumped.
          The default is to update at 01:15 (at night) every day.
        '';
      };

      location = mkOption {
        type = types.str;
        default = "/var/backup/openldap";
        description = ''
          Location to put the gzipped OpenLDAP database dumps.
        '';
      };

      host = mkOption {
        type = types.str;
        description = ''
          URL of the OpenLDAP host to backup;
        '';
        example = "ldap://ldap.example.org";
      };

      basedn = mkOption {
        type = types.str;
        description = ''
          Base DN of the OpenLDAP host.
        '';
        example = "dc=example,dc=org";
      };

      binddn = mkOption {
        type = types.str;
        description = ''
          Distinguished Name to bind the OpenLDAP directory.
        '';
        example = "cn=admin,dc=example,dc=org";
      };

      passwdFile = mkOption {
        type = types.str;
        description = ''
          Path to the BindDN password File.
        '';
        example = "/path/to/secrets";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.openldapBackup =
      openldapBackupService "${config.services.openldap.package}/bin/ldapsearch -H ${cfg.host} -b ${cfg.basedn} -D ${cfg.binddn} -w `${pkgs.coreutils}/bin/cat ${cfg.passwdFile}`";
  };

}
