{
  # Copyright 2025 - Cowboy AI, LLC
  description = "CIM-Start: Domain-Driven Development Starter Kit";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        
        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" "rust-analyzer" ];
        };
      in
      {
        # Development shell
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Rust toolchain
            rustToolchain
            cargo-edit
            cargo-watch
            cargo-audit
            cargo-outdated
            
            # NATS tools
            nats-server
            natscli
            nats-top
            
            # Development tools
            just
            watchexec
            jq
            yq
            
            # Container tools
            docker-compose
            podman-compose
            
            # Documentation
            mdbook
            mermaid-cli
            
            # System tools
            htop
            ripgrep
            fd
            bat
            eza
          ];
          
          shellHook = ''
            echo "🚀 CIM-Start Development Environment"
            echo ""
            echo "Available commands:"
            echo "  nats-server -js    # Start NATS with JetStream"
            echo "  nats stream add    # Create a stream"
            echo "  cargo build        # Build Rust project"
            echo "  cargo test         # Run tests"
            echo "  docker-compose up  # Start NATS stack"
            echo ""
            echo "Quick start:"
            echo "  1. docker-compose up -d"
            echo "  2. cat doc/quick-start.md"
            echo ""
          '';
        };
        
        # NATS server package
        packages.nats-server = pkgs.writeShellScriptBin "cim-nats" ''
          ${pkgs.nats-server}/bin/nats-server \
            -js \
            -sd ./nats-data \
            -m 8222 \
            --name cim-nats-dev
        '';
        
        # Docker compose runner
        packages.stack = pkgs.writeShellScriptBin "cim-stack" ''
          ${pkgs.docker-compose}/bin/docker-compose up -d
          echo "NATS JetStream running at localhost:4222"
          echo "Monitoring at http://localhost:8222"
        '';
        
        # Domain generator
        packages.generate-domain = pkgs.writeShellScriptBin "generate-domain" ''
          DOMAIN_NAME=$1
          if [ -z "$DOMAIN_NAME" ]; then
            echo "Usage: generate-domain <domain-name>"
            exit 1
          fi
          
          echo "Generating domain: $DOMAIN_NAME"
          
          # Create directory structure
          mkdir -p "cim-$DOMAIN_NAME"/{src/domain,src/application,src/infrastructure,tests,doc}
          
          echo "Domain generated at cim-$DOMAIN_NAME/"
          echo "Next steps:"
          echo "  1. cd cim-$DOMAIN_NAME"
          echo "  2. Define your events"
          echo "  3. cargo build"
        '';
        
        # Apps for nix run
        apps = {
          default = {
            type = "app";
            program = "${self.packages.${system}.nats-server}/bin/cim-nats";
          };
          
          nats = {
            type = "app";
            program = "${self.packages.${system}.nats-server}/bin/cim-nats";
          };
          
          stack = {
            type = "app";
            program = "${self.packages.${system}.stack}/bin/cim-stack";
          };
          
          generate = {
            type = "app";
            program = "${self.packages.${system}.generate-domain}/bin/generate-domain";
          };
        };
      });
}