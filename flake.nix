{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };
    utils = {
      url = "github:numtide/flake-utils";
    };
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, utils, crane }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        craneLib = crane.mkLib pkgs;
        requiredPrograms = with pkgs; [ cargo rustc ];
      in
      rec {
        # `nix build`
        packages.default = craneLib.buildPackage ({
          pname = "crane-unused-repro";
          version = "master";
          nativeBuildInputs = requiredPrograms;
          src = craneLib.cleanCargoSource (craneLib.path ./.);
          doCheck = false;
        });

        # `nix develop`
        devShells.default = pkgs.mkShell rec {
          nativeBuildInputs = requiredPrograms;
        };
      });
}
