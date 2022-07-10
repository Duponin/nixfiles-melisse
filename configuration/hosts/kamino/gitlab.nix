{ config, lib, pkgs, ... }:

{
  imports = [ ../../common/nginx.nix ];

  services.gitlab = {
    enable = true;
    host = "git.melisse.org";
    port = 443;
    https = true;

    smtp = { };

    backup = { };

    registry = { };

    databasePasswordFile = "/var/lib/secrets/gitlab/db";

    initialRootPasswordFile = "/var/lib/secrets/gitlab/initialRootPasswordFile";

    secrets = {
      dbFile = "/var/lib/secrets/gitlab/dbFile";
      otpFile = "/var/lib/secrets/gitlab/otpFile";
      jwsFile = "/var/lib/secrets/gitlab/jwsFile";
      secretFile = "/var/lib/secrets/gitlab/secretFile";
    };
  };

  services.nginx = {
    virtualHosts."git.melisse.org" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
    };
  };
}
