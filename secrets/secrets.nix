let
  simon =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINOiFv7rm8ChxvFaggUHRWcgGriWxkfiIPxhUSgTeA6n";
  antonin =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJh6W2o61dlOIcBXeWRhXWSYD/W8FDVf3/p4FNfL2L6p";
  users = [ simon antonin ];

  coreilla =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDiqPblq1nqIQtP9YHkVMD0pwKsyL2yeK6KMdeQYoVrD";
  coruscant =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDvGfzUwQsYZYzAx9fnrsub9yc/9AsGjJzGJSUvhZhxJ";
  florrum =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM5i+V0O8vCVAw/ds4wnz99mRTYP3OgBcVyZuTT4ctWL";
  kessel =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIrjpGuh1fHXlBrGYrCrAHMUJ/IVWOMyZhaFztGLqWyN";
  sullust =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGj4Gqib56G8kKgOUxcZeM4YxEhos41v6Ztrf2/6gs+M";
  systems = [ coreilla kessel ];
in {
  "ldap_admin.age".publicKeys = users ++ [ coreilla kessel ];
  "nextcloud_admin.age".publicKeys = users ++ [ sullust kessel ];
  "sullust_backup_passwd.age".publicKeys = users ++ [ sullust ];
  "coruscant_wireguard_privatekey.age".publicKeys = users ++ [ coruscant ];
  "florrum_wireguard_privatekey.age".publicKeys = users ++ [ florrum ];
}
