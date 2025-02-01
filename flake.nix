{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        #sets
        pkgs = import nixpkgs { inherit system; };
        pkg = nixpkgs.lib.importTOML ./Cargo.toml;
        sharedEnv = {
          WAYLAND_DISPLAY = "wayland-1";
          XDG_RUNTIME_DIR = "/run/user/1000";
          LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath buildInputs}";
        };
        #lists
        buildInputs = import ./modules/buildInputs.wayland.nix { inherit pkgs; };
        shellpackages = import ./modules/packages.nix { inherit pkgs; };
        #functions
        builder = import ./modules/buildPackage.nix;
      in
      rec {
        packages = {
          ${pkg.package.name} =
            builder {
              inherit pkgs pkg buildInputs;
              src = ./.;
            };
        };

        defaultPackage = packages.${pkg.package.name};

        apps = rec {
          cim = flake-utils.lib.mkApp { drv = self.packages.${system}.cim; };
          default = cim;
          drv = self.packages.${system}.${pkg.package.name};
          env = sharedEnv;
        };

        devShells.default = import ./modules/devshell.nix { inherit pkgs buildInputs; packages = shellpackages; env = sharedEnv; };
      }
    );
}






