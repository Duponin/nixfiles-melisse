#!/usr/bin/env bash

nixos-rebuild "$@" -I nixos-config="$(dirname $0)/configuration/hosts/$(hostname)/configuration.nix"

