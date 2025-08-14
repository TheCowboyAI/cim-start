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
            
            # MCP tools
            nodejs
            python3
            python3Packages.pip
            git
            
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
            pgrep
            netstat
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
        
        # MCP service manager
        packages.mcp-manager = pkgs.writeShellScriptBin "mcp-manager" ''
          # Check if MCP processes are already running
          check_mcp_running() {
            local name="$1"
            if pgrep -f "$name" > /dev/null; then
              echo "✓ $name MCP already running"
              return 0
            else
              return 1
            fi
          }
          
          # Start MCP server if not running
          start_mcp() {
            local name="$1"
            local command="$2"
            if ! check_mcp_running "$name"; then
              echo "🚀 Starting $name MCP..."
              nohup $command > "mcp-$name.log" 2>&1 &
              echo "  Started with PID $!"
              echo "  Logs: mcp-$name.log"
            fi
          }
          
          case "$1" in
            start)
              echo "🔧 Starting MCP servers..."
              start_mcp "nixmcp" "python -m mcp_nixos.server"
              start_mcp "sequential-thinking" "npx mcp-server-sequential-thinking"
              start_mcp "github" "npx mcp-server-github"
              start_mcp "cim-network" "python3 -m cim_network_mcp"
              ;;
            stop)
              echo "🛑 Stopping MCP servers..."
              pkill -f "mcp_nixos.server" || true
              pkill -f "mcp-server-sequential-thinking" || true  
              pkill -f "mcp-server-github" || true
              pkill -f "cim_network_mcp" || true
              ;;
            status)
              echo "📊 MCP Server Status:"
              check_mcp_running "mcp_nixos.server" || echo "❌ nixmcp not running"
              check_mcp_running "mcp-server-sequential-thinking" || echo "❌ sequential-thinking not running"
              check_mcp_running "mcp-server-github" || echo "❌ github not running"
              check_mcp_running "cim_network_mcp" || echo "❌ cim-network not running"
              ;;
            *)
              echo "Usage: mcp-manager {start|stop|status}"
              echo ""
              echo "Available MCP servers:"
              echo "  - nixmcp: System configuration MCP"
              echo "  - sequential-thinking: Reasoning MCP"
              echo "  - github: GitHub integration MCP"
              echo "  - cim-network: Network topology builder MCP"
              ;;
          esac
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

        # CIM-Start orchestrator
        packages.cim-start = pkgs.writeShellScriptBin "cim-start" ''
          echo "🚀 CIM-Start Orchestrator"
          echo ""
          
          # Check prerequisites
          echo "📋 Checking prerequisites..."
          
          # Check if NATS is running
          if netstat -tln 2>/dev/null | grep -q ":4222 "; then
            echo "✓ NATS JetStream running on port 4222"
            NATS_RUNNING=true
          else
            echo "❌ NATS not running - starting NATS..."
            ${pkgs.docker-compose}/bin/docker-compose up -d nats
            sleep 3
            NATS_RUNNING=false
          fi
          
          # Check and start MCP servers
          echo ""
          echo "🔧 Managing MCP servers..."
          ${self.packages.${system}.mcp-manager}/bin/mcp-manager status
          ${self.packages.${system}.mcp-manager}/bin/mcp-manager start
          
          echo ""
          echo "✅ CIM-Start Environment Ready!"
          echo ""
          echo "Next steps:"
          echo "  1. claude '@network-expert Set up network topology'"
          echo "  2. claude '@domain-expert Create my domain'"
          echo "  3. Start building with events and graphs"
          echo ""
          echo "Monitoring:"
          echo "  - NATS: http://localhost:8222"
          echo "  - MCP Logs: mcp-*.log files"
        '';
        
        # Apps for nix run
        apps = {
          default = {
            type = "app";
            program = "${self.packages.${system}.cim-start}/bin/cim-start";
          };
          
          start = {
            type = "app";
            program = "${self.packages.${system}.cim-start}/bin/cim-start";
          };
          
          mcp = {
            type = "app";
            program = "${self.packages.${system}.mcp-manager}/bin/mcp-manager";
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