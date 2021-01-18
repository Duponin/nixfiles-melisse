{ lib, config, ... }:
with lib;
let cfg = config.monitoring.client;
in {
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
      type = types.list;
      default = [ "2a0c:e304:c0fe::/48" "::1" ];
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    services.netdata.enable = true;
    services.nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
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
            allow ${
              concatMapStrings (x: ''
                allow ${x} ;
              '') cfg.allowedIPs
            };
            deny all;
          '';
        };
      };
    };
    security.acme = {
      acceptTerms = true;
      email = "admin+acme@melisse.org";
    };
  };
}
