with import <nixpkgs> { };

let
  sources = import ./nix/sources.nix;
  agenix = callPackage (sources.agenix + "/pkgs/agenix.nix") { };
in mkShell { buildInputs = [ agenix ]; }
