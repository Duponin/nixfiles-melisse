{ ... }:

{
  fileSystems."/var/lib/backups/heuzef" = {
    device = "/dev/disk/by-uuid/11c7cc91-d00b-4102-b825-09eed543287b";
    fsType = "ext4";
  };

  services.borgbackup.repos = {
    heuzef_backup = {
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICSgG6qWSX+b97o0JYSJ3wwVRiE9F/HQsJ0560fprUBX root@backup"
      ];
      path = "/var/lib/backups/heuzef/backup";
    };
  };
}
