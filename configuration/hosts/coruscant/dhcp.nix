{ config, ... }:

{
  # DHCPv4
  # It is only used on a dedicated bridge to allow legacy compatibility
  # It may be merged on the main bridge or maybe removed one day 6to4 ?
  networking.firewall.interfaces.br-vm-nat.allowedUDPPorts = [ 67 ];
  services.dhcpd4 = {
    enable = true;
    interfaces = [ "br-vm-nat" ];
    extraConfig = ''
      option subnet-mask 255.255.0.0;
      option broadcast-address 10.1.255.255;
      option routers 10.1.0.1;
      option domain-name-servers 185.233.100.100;
      option domain-name "melisse.org";
      subnet 10.1.0.0 netmask 255.255.0.0 {
        range 10.1.0.10 10.1.1.250;
      }
    '';
  };

  # DHCPv6
  networking.firewall.interfaces.br-vm-lan.allowedUDPPorts = [ 547 ];
  systemd.services.dhcpd6.serviceConfig.AmbientCapabilities = [ "CAP_NET_RAW" ];
  services.dhcpd6 = {
    enable = true;
    interfaces = [ "br-vm-lan" ];
    extraConfig = ''
      option dhcp6.name-servers 2a0c:e300::100;
      subnet6 2a0c:e304:c0fe:1::/64 {
        range6 2a0c:e304:c0fe:1::D:1 2a0c:e304:c0fe:1::D:FFFF;
      }
    '';
  };
}
