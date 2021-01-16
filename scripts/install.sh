#!/usr/bin/env bash

set -e

(
  REPO="https://git.locahlo.st/chatons/nixfiles"

  INSTALL_DEVICE="${1}"
  HOSTNAME="${2}"

  BOOT_DEVICE="${INSTALL_DEVICE}1"
  ROOT_DEVICE="${INSTALL_DEVICE}2"

  if [ -z "$HOSTNAME" ] || [ -z "$INSTALL_DEVICE" ]; then
    echo "Please give arguments. <INSTALL_DEVICE> then <HOSTNAME>"
    exit 1
  fi

  hostname "${HOSTNAME}"

  parted --script "${INSTALL_DEVICE}" -- mklabel gpt
  parted --script "${INSTALL_DEVICE}" -- mkpart ESP fat32 1MiB 512MiB
  parted --script "${INSTALL_DEVICE}" -- set 1 esp on
  parted --script "${INSTALL_DEVICE}" -- mkpart primary 512MiB 100%FREE

  mkfs.fat -F 32 -n boot "${BOOT_DEVICE}"
  mkfs.ext4 "${ROOT_DEVICE}" -L nixos

  mount "${ROOT_DEVICE}" /mnt
  mkdir /mnt/boot
  mount "${BOOT_DEVICE}" /mnt/boot

  nix-env -iA nixos.git
  git clone "${REPO}" /mnt/etc/nixfiles

  nixos-install --no-root-passwd -I "nixos-config=/mnt/etc/nixfiles/configuration/hosts/${HOSTNAME}/configuration.nix"

  reboot
)
