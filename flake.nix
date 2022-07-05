{
  inputs.nixos.url = "github:NixOS/nixpkgs/nixos-22.05";

  outputs = { self,nixos }: {
    nixosConfigurations = {
      borg = nixos.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./configuration/hosts/borg/configuration.nix ];
      };
    };
  };
}
