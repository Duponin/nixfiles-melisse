{ config, lib, pkgs, ... }:

{
  imports = [
    "${
      builtins.fetchTarball
      "https://github.com/ryantm/agenix/archive/refs/tags/0.10.1.tar.gz"
    }/modules/age.nix"
  ];
}
