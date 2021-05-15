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

      backupCmd = mkOption {
        type = types.str;
        description = ''
          The backup command to create an openLDAP dump.
        '';
        example = "slapcat -n 1";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d '${cfg.location}' 0700 openldap - - -"
    ];
    systemd.services.openldapBackup =
      openldapBackupService "${config.services.openldap.package}/bin/${cfg.backupCmd}";
  };

}
