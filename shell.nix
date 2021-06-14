with import <nixpkgs> { };

let
  sources = import ./nix/sources.nix;
  agenix = callPackage (sources.agenix + "/pkgs/agenix.nix") { };
  morph = callPackage (sources.morph) { };
in mkShell { buildInputs = [ agenix niv morph wireguard ]; }
