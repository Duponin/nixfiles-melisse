{ config, ... }:

{
  virtualisation.docker = {
    enable = true;
    extraOptions = ''
      --ip="127.0.0.1" \
    '';
  };

  services.nginx.virtualHosts."portainer.melisse.org" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://localhost:9000";
      extraConfig = ''
        proxy_ssl_server_name on;
      '';
    };
  };
}
