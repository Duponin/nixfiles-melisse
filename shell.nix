with import <nixpkgs> { };

let
  sources = import ./nix/sources.nix;
  morph = callPackage (sources.morph) { };
in mkShell { buildInputs = [ niv morph wireguard ]; }
