{
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
        
        # NATS VM configuration
        packages.nats-vm = self.nixosConfigurations.${system}.nats-vm.config.system.build.vm;
        
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
          
          # Copy templates
          cp -r ${./templates}/* "cim-$DOMAIN_NAME/"
          
          # Replace placeholders
          find "cim-$DOMAIN_NAME" -type f -exec sed -i "s/{{DOMAIN_NAME}}/$DOMAIN_NAME/g" {} \;
          
          echo "Domain generated at cim-$DOMAIN_NAME/"
          echo "Next steps:"
          echo "  1. cd cim-$DOMAIN_NAME"
          echo "  2. Edit src/domain/events.rs"
          echo "  3. cargo build"
        '';
        
        # Apps for nix run
        apps = {
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
        
        # NixOS configurations
        nixosConfigurations.nats-vm = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ({ config, pkgs, ... }: {
              # VM settings
              virtualisation = {
                cores = 2;
                memorySize = 2048;
                diskSize = 10240;
                
                forwardPorts = [
                  { from = "host"; host.port = 4222; guest.port = 4222; }
                  { from = "host"; host.port = 8222; guest.port = 8222; }
                  { from = "host"; host.port = 6222; guest.port = 6222; }
                ];
              };
              
              # NATS service
              services.nats = {
                enable = true;
                jetstream = true;
                
                settings = {
                  server_name = "cim-nats-vm";
                  listen = "0.0.0.0:4222";
                  monitor_port = 8222;
                  
                  jetstream = {
                    store_dir = "/var/lib/nats/jetstream";
                    max_memory_store = "512MB";
                    max_file_store = "2GB";
                  };
                  
                  cluster = {
                    name = "cim-cluster";
                    listen = "0.0.0.0:6222";
                  };
                  
                  debug = false;
                  trace = false;
                  logtime = true;
                  
                  max_connections = 1000;
                  max_payload = "1MB";
                  max_pending = "64MB";
                };
              };
              
              # Firewall
              networking.firewall = {
                enable = true;
                allowedTCPPorts = [ 4222 6222 8222 ];
              };
              
              # System packages
              environment.systemPackages = with pkgs; [
                natscli
                vim
                htop
                tmux
              ];
              
              # Auto-initialize streams
              systemd.services.nats-init = {
                description = "Initialize NATS JetStream streams";
                after = [ "nats.service" ];
                requires = [ "nats.service" ];
                wantedBy = [ "multi-user.target" ];
                
                script = ''
                  sleep 5
                  
                  # Create EVENTS stream
                  ${pkgs.natscli}/bin/nats stream add EVENTS \
                    --subjects "event.>" \
                    --retention limits \
                    --max-msgs=1000000 \
                    --max-age=7d \
                    --storage file \
                    --replicas 1 \
                    --no-allow-rollup \
                    --discard old \
                    --dupe-window 2m || true
                  
                  # Create COMMANDS stream  
                  ${pkgs.natscli}/bin/nats stream add COMMANDS \
                    --subjects "cmd.>" \
                    --retention interest \
                    --max-age=1h \
                    --storage memory \
                    --replicas 1 || true
                  
                  # Create PROJECTIONS stream
                  ${pkgs.natscli}/bin/nats stream add PROJECTIONS \
                    --subjects "projection.>" \
                    --retention limits \
                    --max-msgs-per-subject=1 \
                    --storage file \
                    --replicas 1 \
                    --allow-rollup || true
                  
                  echo "NATS JetStream initialized with streams"
                '';
                
                serviceConfig = {
                  Type = "oneshot";
                  RemainAfterExit = true;
                };
              };
              
              # Boot message
              services.getty.helpLine = ''
                
                === CIM NATS JetStream VM ===
                
                NATS is running on:
                  Client: localhost:4222
                  Monitor: http://localhost:8222
                  Cluster: localhost:6222
                
                Available streams:
                  - EVENTS (event.>)
                  - COMMANDS (cmd.>)
                  - PROJECTIONS (projection.>)
                
                Tools available:
                  - nats: CLI for NATS
                  - nats stream: Manage streams
                  - nats consumer: Manage consumers
                
              '';
            })
          ];
        };
      });
}