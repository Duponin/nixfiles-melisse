{ config, pkgs, ... }:
let hostname = "sullust";
in {
  imports = [ # imports
    ../../../modules/monitoring/client.nix
    ../../common
    ../../common/qemu-guest
    ../../common/qemu-guest/uefi.nix
  ];

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  monitoring.client.enable = true;
  monitoring.client.host = hostname;

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts."dolibarr.melisse.org" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://dolibarr.priv.melisse.org";
        extraConfig = ''
          proxy_ssl_server_name on;
        '';
      };
    };
  };
  security.acme = {
    acceptTerms = true;
    email = "admin+acme@melisse.org";
  };

  networking = {
    defaultGateway6 = {
      address = "2a0c:e304:c0fe:1::1";
      interface = "ens3";
    };
    hostName = hostname;
    nameservers = [ "2a0c:e300::100" "2a0c:e300::101" ];
    interfaces = {
      ens3 = {
        mtu = 1500;
        ipv6 = {
          addresses = [{
            address = "2a0c:e304:c0fe:1::5";
            prefixLength = 64;
          }];
        };
      };
      ens4.useDHCP = true;
    };
  };

  system.stateVersion = "20.09";
}
