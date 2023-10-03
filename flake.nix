# https://github.com/fbrausse/fxprog
{
  description = "fxprog";

  nixConfig.bash-prompt-prefix = "(fxprog) ";

  inputs = { 
    nixpkgs.url = "github:nixos/nixpkgs/23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nix, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      packageName = "fxprog";
    in rec {
      packages.${packageName} = pkgs.stdenv.mkDerivation {
        name = packageName;
        src = ./.;
        buildInputs = with pkgs; [
          libusb1
          pkg-config
        ];

# make -f makefile -e CFLAGS="$NIX_CFLAGS_COMPILE" LDFLAGS="$NIX_LDFLAGS"
        buildPhase = ''
          make
          #cd ./src ; g++ -o download_fx3 download_fx3.cpp $NIX_CFLAGS_COMPILE -L ../lib -l cyusb -l usb-1.0
        '';

        installPhase = ''
          mkdir -p $out/bin
          cp bulk $out/bin/fxprog_bulk
          cp ctl $out/bin/fxprog_ctl
          cp fxprog $out/bin
        '';
      };
  
      packages.default = self.packages.${system}.${packageName};

      devShells.default = pkgs.mkShell {
        packages = [
          self.packages.${system}.default
        ];
      };
    });
}
