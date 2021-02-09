let
  simon =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINOiFv7rm8ChxvFaggUHRWcgGriWxkfiIPxhUSgTeA6n";
  antonin =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJh6W2o61dlOIcBXeWRhXWSYD/W8FDVf3/p4FNfL2L6p";
  users = [ simon antonin ];

  coreilla =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDiqPblq1nqIQtP9YHkVMD0pwKsyL2yeK6KMdeQYoVrD";
  kessel =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIrjpGuh1fHXlBrGYrCrAHMUJ/IVWOMyZhaFztGLqWyN";
  sullust =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGj4Gqib56G8kKgOUxcZeM4YxEhos41v6Ztrf2/6gs+M";
  malastare =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE95SUeLCzTzcHUK7VPDEgXEFdpgHlr3efgTdDSU3m0f";
  systems = [ coreilla kessel ];
in {
  "ldap_admin.age".publicKeys = users ++ [ coreilla kessel ];
  "nextcloud_admin.age".publicKeys = users ++ [ sullust kessel ];
  "sullust_backup_passwd.age".publicKeys = users ++ [ sullust ];
  "malastare_backup_passwd.age".publicKeys = users ++ [ malastare ];
}
