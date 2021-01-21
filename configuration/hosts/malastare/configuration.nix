{ config, pkgs, ... }:
let hostname = "malastare";
in {
  imports = [ # imports
    ../../../modules/monitoring/client.nix
    ../../common
    ../../common/qemu-guest
    ../../common/qemu-guest/uefi.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  monitoring.client.enable = true;
  monitoring.client.host = hostname;

  # Set networking
  networking = {
    defaultGateway6 = {
      address = "2a0c:e300:12::190";
      interface = "ens3";
    };
    defaultGateway = {
      address = "185.233.102.190";
      interface = "ens3";
    };
    firewall.checkReversePath = false;
    hostName = "malastare";
    nameservers = [ "185.233.100.100" "185.233.100.101" "1.1.1.1" ];
    interfaces.ens3 = {
      mtu = 1378;
      ipv4 = {
        addresses = [{
          address = "185.233.102.134";
          prefixLength = 26;
        }];
      };
      ipv6 = {
        addresses = [{
          address = "2a0c:e300:12::134";
          prefixLength = 48;
        }];
      };
    };
    interfaces.ens4 = {
      ipv6 = {
        addresses = [
          {
            address = "2a0c:e304:c0fe::1";
            prefixLength = 64;
          }
          {
            address = "2a0c:e304:c0fe:1::1";
            prefixLength = 64;
          }
        ];
      };
    };
    interfaces.ens10 = {
      ipv4 = {
        addresses = [{
          address = "10.1.0.1";
          prefixLength = 16;
        }];
      };
    };
  };

  services.borgbackup.jobs.aedu = {
    paths = [ "/var/log" ];
    doInit = true;
    repo = "borg@aedu.melisse.org:/var/lib/backup/melisse/malastare";
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat /root/backup.key";
    };
    environment = { BORG_RSH = "ssh -i /etc/ssh/ssh_host_ed25519_key"; };
    compression = "auto,lzma";
    startAt = "daily";
  };

  networking.firewall.interfaces.ens10.allowedUDPPorts = [ 67 ];
  networking.nat = {
    enable = true;
    internalIPs = [ "10.1.0.0/16" ];
    internalInterfaces = [ "ens5" ];
    externalIP = "185.233.102.134";
    externalInterface = "ens3";
  };
  services.dhcpd4 = {
    enable = true;
    interfaces = [ "ens10" ];
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

  system.stateVersion = "20.09";
}
