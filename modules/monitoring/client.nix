{ lib, config, ... }:
with lib;
let cfg = config.monitoring.client;
in {
  imports = [ ../../configuration/common/nginx.nix ];
  options.monitoring.client = {
    enable = mkEnableOption "Enable the monitoring endpoint client";
    host = mkOption {
      type = types.str;
      default = "";
    };
    domain = mkOption {
      type = types.str;
      default = "melisse.org";
    };
    allowedIPs = mkOption {
      type = types.listOf types.str;
      default = [ "2a0c:e304:c0fe::/48" "::1" ];
    };
  };

  config = mkIf cfg.enable {
    services.netdata.enable = true;
    services.nginx = {
      virtualHosts."${cfg.host + "." + cfg.domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/.well-known" = {
          extraConfig = ''
            proxy_ssl_server_name on;
          '';
        };
        locations."/" = {
          proxyPass = "http://localhost:19999";
          extraConfig = ''
            proxy_ssl_server_name on;
            ${concatMapStrings (x: ''
              allow ${x};
            '') cfg.allowedIPs}
            deny all;
          '';
        };
      };
    };
  };
}
