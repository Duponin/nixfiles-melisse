{ lib, config, ... }:
with lib;
let cfg = config.backup.client;
in {
  options.backup.client = {
    enable = mkEnableOption "Enable the backup client";
    host = mkOption {
      type = types.str;
      default = "";
    };
    paths = mkOption {
      type = types.listOf types.str;
      default = [ "" ];
    };
  };

  config = mkIf cfg.enable {
    services.borgbackup.jobs.aedu = {
      paths = cfg.paths;
      doInit = true;
      repo = "borg@aedu.melisse.org:/var/lib/backups/melisse/${cfg.host}";
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat /root/backup.key";
      };
      environment = { BORG_RSH = "ssh -i /etc/ssh/ssh_host_ed25519_key"; };
      compression = "auto,lzma";
      startAt = "daily";
      prune.keep = {
        within = "1d"; # Keep all archives from the last day
        daily = 7;
        weekly = 4;
        monthly = -1; # Keep at least one archive for each month
      };
    };
  };
}
