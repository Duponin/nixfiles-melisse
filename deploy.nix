let
  # Pin the deployment package-set to a specific version of nixpkgs
  pkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/20.09.tar.gz";
    sha256 = "a26a85bd98253f560c55ec48be1c793c39f471a6fb9842f9af07a701e854f9bf";
  }) { };
in {
  network = {
    inherit pkgs;
    description = "Mélisse hosts";
    ordering = { tags = [ "prod" ]; };
  };

  "coreilla.melisse.org" = { config, pkgs, ... }: {
    deployment.tags = [ "prod" ];
    imports = [ ./configuration/hosts/coreilla/configuration.nix ];
  };
}
