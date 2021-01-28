{
  network = {
    description = "Mélisse hosts";
    ordering = { tags = [ "prod" ]; };
  };

  "coreilla.melisse.org" = { config, pkgs, ... }: {
    deployment.tags = [ "prod" ];
    imports = [ ./configuration/hosts/coreilla/configuration.nix ];
  };
}
