{ config, lib, pkgs, ... }:

{
  imports = [ ../../common/secrets.nix ];
  age.secrets.wireguard_privatekey.file =
    ../../../secrets/coruscant_wireguard_privatekey.age;
  networking.wireguard = {
    enable = true;
    interfaces = {
      wg0 = {
        ips = [ "2a0c:e304:c0fe:20::1/64" ];
        listenPort = 51820;
        privateKeyFile = "/run/agenix/wireguard_privatekey";
        peers = [
          {
            publicKey = "LipBKld4iV7jYcE4tdIuscULUZs45+/g3BoPXZ4u41M=";
            allowedIPs = [ "2a0c:e304:c0fe:20::11/128" ];
          }
          {
            publicKey = "p1+fAZ1if362mNI+5Lgi3v+NVUm2yEubEFMAqzeuPVk=";
            allowedIPs = [ "2a0c:e304:c0fe:20::12/128" ];
          }
        ];
      };
    };
  };
  networking.firewall.allowedUDPPorts = [ 51820 ];
}
