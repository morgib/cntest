{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cargo2nix = {
      url = "github:cargo2nix/cargo2nix/release-0.11.0";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    flake-utils.follows = "cargo2nix/flake-utils";
  };

  outputs = inputs:
    with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ cargo2nix.overlays.default ];
          #overlays = [ rust-overlay.overlays.default ];
        };

        rustPkgs = pkgs.rustBuilder.makePackageSet {
          rustVersion = "1.77.2";
          packageFun = import ./Cargo.nix;
          extraRustComponents = [ "clippy" "rust-analyzer" ];
        };

      in rec {
        packages = {
          # replace hello-world with your package name
          cntest = (rustPkgs.workspace.cntest { });
          default = packages.cntest;
        };
      });
}
