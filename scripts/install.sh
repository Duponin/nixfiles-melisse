#!/usr/bin/env bash

set -e

(
  REPO="https://git.locahlo.st/chatons/nixfiles.git"

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

  # Install system from another git branch
  if [ $INSTALL_BRANCH ]; then
    git -C /mnt/etc/nixfiles switch "${INSTALL_BRANCH}"
  fi

  # FIXME Workaround because `nixos-install` don't honour `nixos-config` correctly
  # We could use `NIXOS_CONF` env var, should be a better workaround than below
  mkdir /mnt/etc/nixos
  touch /mnt/etc/nixos/configuration.nix

  nixos-install --no-root-passwd -I "nixos-config=/mnt/etc/nixfiles/configuration/hosts/${HOSTNAME}/configuration.nix"

  reboot
)
