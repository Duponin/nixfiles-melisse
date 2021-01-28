{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    "${
      builtins.fetchTarball
      "https://codeload.github.com/ryantm/agenix/tar.gz/master"
    }/modules/age.nix"
  ];

  boot.initrd.availableKernelModules =
    [ "ata_piix" "uhci_hcd" "ehci_pci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  swapDevices = [ ];

  networking.useDHCP = false;
}
