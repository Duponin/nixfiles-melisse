{ config, lib, pkgs, ... }:

{
  imports = [ ../../common/secrets.nix ];
  age.secrets.wireguard_privatekey.file =
    ../../../secrets/coruscant_wireguard_privatekey.age;
  networking.wireguard = {
    enable = true;
    interfaces = {
      wg0 = {
        ips = [ "2a0c:e304:c0fe:20::/48" ];
        listenPort = 51820;
        privateKeyFile = "/run/secrets/wireguard_privatekey";
        peers = [{
          publicKey = "LipBKld4iV7jYcE4tdIuscULUZs45+/g3BoPXZ4u41M=";
          allowedIPs = [ "2a0c:e304:c0fe:20::11/128" ];
        }];
      };
    };
  };
  networking.firewall.allowedUDPPorts = [ 51820 ];
}
