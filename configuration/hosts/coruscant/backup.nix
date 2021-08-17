{ ... }:

{
  fileSystems."/var/lib/backups/heuzef" = {
    device = "/dev/disk/by-uuid/66978328-978a-4943-b832-88201482756f";
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
