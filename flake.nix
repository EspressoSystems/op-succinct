{
  description = "Dev shell for op-succinct (tests via just)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            rustc
            cargo
            rustfmt
            clippy
            just
            pkg-config
            openssl
            protobuf
            clang
            cmake
            git
            jq
            zlib
            curl
          ];
        };
      });
}
