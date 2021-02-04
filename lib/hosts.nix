{ pkgs, ... }:

with pkgs.lib;

rec {
  hostsDir = ../configuration/hosts;
  hosts = attrNames
    (filterAttrs (name: type: type == "directory") (builtins.readDir hostsDir));
}
