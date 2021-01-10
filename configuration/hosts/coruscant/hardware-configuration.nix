{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules =
    [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/0f2cba63-503f-445a-8743-79232223f8a6";
    fsType = "ext4";
  };

  fileSystems."/boot2" = {
    device = "/dev/disk/by-uuid/ea7d98cf-5439-48ec-9e88-d58dc0393fe3";
    fsType = "ext4";
  };

  fileSystems."/boot1" = {
    device = "/dev/disk/by-uuid/7e50bb9d-4ee0-4710-92bc-baa38011f192";
    fsType = "ext4";
  };

  swapDevices = [ ];

}
