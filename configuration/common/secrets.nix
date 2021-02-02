{ config, lib, pkgs, ... }:

{
  imports = [
    "${
      builtins.fetchTarball
      "https://github.com/ryantm/agenix/archive/master.tar.gz"
    }/modules/age.nix"
  ];
}
