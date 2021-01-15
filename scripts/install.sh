#!/usr/bin/env bash

set -e

REPO="https://git.locahlo.st/chatons/nixfiles"

device="${1}"
hostname="${2}"

if [ -z "$hostname" ] || [ -z "$device" ]; then
  echo "Please give arguments. <device> then <hostname>"
  exit 1
fi

hostname "${hostname}"
parted "${device}" -- mklabel msdos
parted "${device}" -- mkpart primary 0% 100%
mkfs.ext4 "${device}"1 -L nixos
mount "${device}"1 /mnt
nixos-generate-config --root /mnt
nix-env -iA nixos.git
git clone "${REPO}" /mnt/etc/nixfiles
nixos-install --no-root-passwd -I nixos-config=/mnt/etc/nixfiles/configuration/hosts/"${hostname}"/configuration.nix

echo "Installation Done! Reboot and enjoy..."
