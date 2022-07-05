{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.availableKernelModules = [ # missing modules?
    "ata_piix"
    "ehci_pci"
    "sd_mod"
    "sr_mod"
    "uhci_hcd"
    "virtio_pci"
    "virtio_scsi"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  services.qemuGuest.enable = true;

  swapDevices = [ ];

  networking.useDHCP = false;
}
