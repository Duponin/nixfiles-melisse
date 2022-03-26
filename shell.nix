with import <nixpkgs> { };

let
  morph = callPackage (sources.morph) { };
in mkShell { buildInputs = [ morph wireguard ]; }
