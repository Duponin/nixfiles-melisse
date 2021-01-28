let
  # Pin the deployment package-set to a specific version of nixpkgs
  pkgs = import (builtins.fetchTarball {
    url =
      "https://github.com/NixOS/nixpkgs-channels/archive/51d115ac89d676345b05a0694b23bd2691bf708a.tar.gz";
    sha256 = "1gfjaa25nq4vprs13h30wasjxh79i67jj28v54lkj4ilqjhgh2rs";
  }) { };
in {
  network = {
    description = "Mélisse hosts";
    ordering = { tags = [ "prod" ]; };
  };

  "coreilla.melisse.org" = { config, pkgs, ... }: {
    deployment.tags = [ "prod" ];
    imports = [ ./configuration/hosts/coreilla/configuration.nix ];
  };
}
