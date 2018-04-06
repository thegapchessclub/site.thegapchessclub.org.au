{ nixpkgs ? import <nixpkgs> {}
}:
let
  inherit (nixpkgs) pkgs;

  # Import the nix package for our site generator
  generator = import ./generator;
  # Import the nix package for our generated site
  blog = import ./content {
    inherit generator;
  };

  jobs = rec {
    inherit generator;
    inherit blog;
  };
in
  jobs
