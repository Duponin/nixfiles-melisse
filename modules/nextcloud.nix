{ pkgs, lib, config, ... }:

with lib;
with builtins;

let

  cfg = config.nextcloud;

  # Cleanup override info
  settings = pkgs.lib.mapAttrsRecursiveCond (s: !s ? "_type")
    (_: value: if value ? "content" then value.content else value) cfg.settings;

in {

  options.nextcloud = {

    enable = mkEnableOption "Enable nextcloud";

    url = mkOption {
      type = types.str;
      default = "";
      description = "URL of the Nextcloud installation";
    };

    apps = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "List of nextcloud apps to install & enable";
    };

    settings = mkOption {
      type = types.attrsOf types.attrs;
      default = { };
      description =
        "Nextcloud settings to be imported using `occ config:import`";
    };
  };

  config = mkIf cfg.enable {

    services.postgresql = {
      enable = true;
      authentication = ''
        host all all 127.0.0.1/32 trust
        host all all ::1/128      trust
      '';
      ensureDatabases = [ "nextcloud" ];
      ensureUsers = [{
        name = "nextcloud";
        ensurePermissions = { "DATABASE nextcloud" = "ALL PRIVILEGES"; };
      }];
      # FIXME: user nextcloud has to be nextcloud database's owner
      # sudo -u postgres psql
      # ALTER DATABASE nextcloud owner to nextcloud;
    };

    services.nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      virtualHosts = {
        "${cfg.url}" = {
          default = true;
          forceSSL = true;
          enableACME = true;
        };
      };
    };

    services.nextcloud = {
      enable = true;
      https = true;
      package = pkgs.nextcloud20;
      hostName = "${cfg.url}";
      config = {
        dbname = "nextcloud";
        dbport = 5432;
        dbtype = "pgsql";
        adminpassFile = "/run/secrets/nextcloud_admin";
        overwriteProtocol = "https";
      };
    };

    systemd.services.nextcloud-setup = {
      serviceConfig.RemainAfterexit = true;
      partOf = [ "phpfpm-nextcloud.service" ];
      after = [ "postgresql.service" ];
      requires = [ "postgresql.service" ];
      script = mkAfter ''
        nextcloud-occ app:enable ${concatStringsSep " " cfg.apps}
        echo '${toJSON settings}' | nextcloud-occ config:import
      '';
    };

  };
}
