{
  network = {
    description = "Mélisse hosts";
    ordering = { tags = [ "prod" ]; };
  };

  "aedu.melisse.org" = { config, pkgs, ... }: {
    deployment.tags = [ "prod" ];
    imports = [ ./configuration/hosts/aedu/configuration.nix ];
  };
  "anoat.melisse.org" = { config, pkgs, ... }: {
    deployment.tags = [ "prod" ];
    imports = [ ./configuration/hosts/anoat/configuration.nix ];
  };
  "coreilla.melisse.org" = { config, pkgs, ... }: {
    deployment.tags = [ "prod" ];
    imports = [ ./configuration/hosts/coreilla/configuration.nix ];
  };
  "malastare.melisse.org" = { config, pkgs, ... }: {
    deployment.tags = [ "prod" ];
    imports = [ ./configuration/hosts/malastare/configuration.nix ];
  };
  "rishi.melisse.org" = { config, pkgs, ... }: {
    deployment.tags = [ "prod" ];
    imports = [ ./configuration/hosts/rishi/configuration.nix ];
  };
  "sullust.melisse.org" = { config, pkgs, ... }: {
    deployment.tags = [ "prod" ];
    imports = [ ./configuration/hosts/sullust/configuration.nix ];
  };
}
