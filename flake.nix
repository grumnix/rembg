{
  description = "Image background removal tool";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    flake-utils.url = "github:numtide/flake-utils";

    pypi-deps-db = {
      url = "github:DavHau/pypi-deps-db";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.mach-nix.follows = "mach-nix";
    };

    mach-nix = {
      url = "github:DavHau/mach-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pypi-deps-db.follows = "pypi-deps-db";
    };

    rembg_src = {
      url = "github:danielgatis/rembg";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, mach-nix, rembg_src, ... }:
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in {
      packages = rec {
        default = rembg;
        rembg = mach-nix.lib.${system}.buildPythonPackage {
          src = rembg_src;

          postPatch = ''
            substituteInPlace setup.py \
              --replace '"opencv-python-headless>=4.6.0.66",' \
                         ""
          '';

          requirements = builtins.replaceStrings
            ["opencv-python-headless==4.6.0.66"
             "fastapi==0.87.0"]
            ["opencv"
             "fastapi"]
            (builtins.readFile "${rembg_src}/requirements.txt");
        };
      };
    }
  );
}
