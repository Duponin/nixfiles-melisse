#!/usr/bin/env bash

REPO="https://git.locahlo.st/chatons/nixfiles"

read -p "Device? (/dev/sda): " device; device=${device:-/dev/sda}
read -p "Hostname? " hostname

if [ -z "$hostname" ]; then
  echo "Please give a hostname."
  exit 1
fi

hostname ${hostname}
parted ${device} -- mklabel msdos
parted ${device} -- mkpart primary 0% 100%
mkfs.ext4 ${device}1 -L nixos
mount ${device}1 /mnt
nixos-generate-config --root /mnt
nix-env -iA nixos.git
git clone ${REPO} /mnt/etc/nixfiles
nixos-install --no-root-passwd -I nixos-config=/mnt/etc/nixfiles/configuration/${hostname}/configuration.nix

echo "Installation Done! Reboot and enjoy..."
