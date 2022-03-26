{
  network = {
    description = "Mélisse hosts";
    ordering = { tags = [ "prod" ]; };
  };

  "borg.melisse.org" = { config, pkgs, ... }: {
    deployment.tags = [ "prod" ];
    imports = [ ./configuration/hosts/sullust/configuration.nix ];
  };
}
