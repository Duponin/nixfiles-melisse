{ config, ... }:

{
  # Allow packet forwarding
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  # NAT to access the shameful remotes which are IPv4 only
  networking.nat = {
    enable = true;
    internalIPs = [ "10.1.0.0/16" ];
    internalInterfaces = [ "br-vm-nat" ];
    externalIP = "185.233.102.133";
    externalInterface = "enp38s0";
  };

  # Needed to have IPv6 routing to work
  services.radvd = {
    enable = true;
    config = ''
      interface ens4 {
        AdvSendAdvert on;
        AdvManagedFlag on;
        prefix 2a0c:e304:c0fe:1::/64 {
          AdvRouterAddr on;
        };
      };
    '';
  };
}
