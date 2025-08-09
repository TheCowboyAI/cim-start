# NATS JetStream Setup Guide

## 🚀 Quick Start Options

### Option 1: Docker (Fastest - 2 minutes)

```bash
# Start NATS with JetStream
docker run -d \
  --name nats-js \
  -p 4222:4222 \
  -p 8222:8222 \
  nats:latest \
  -js -m 8222

# Verify it's running
curl http://localhost:8222/healthz

# Connect with CLI
docker exec -it nats-js nats-cli
```

### Option 2: Docker Compose (Recommended - 5 minutes)

Create `docker-compose.yml`:
```yaml
version: '3.8'

services:
  nats:
    image: nats:2.10-alpine
    container_name: cim-nats
    ports:
      - "4222:4222"  # Client connections
      - "8222:8222"  # HTTP monitoring
      - "6222:6222"  # Cluster routing
    command: 
      - "-js"                 # Enable JetStream
      - "-sd"                 # Storage directory
      - "/data"
      - "-m"                  # Monitoring port
      - "8222"
      - "--name"              # Server name
      - "cim-nats-1"
    volumes:
      - nats-data:/data
      - ./nats.conf:/etc/nats/nats.conf:ro
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8222/healthz"]
      interval: 10s
      timeout: 5s
      retries: 5

  nats-box:
    image: natsio/nats-box:latest
    container_name: cim-nats-box
    depends_on:
      - nats
    command: sleep infinity
    volumes:
      - ./scripts:/scripts

volumes:
  nats-data:
    driver: local
```

Start the stack:
```bash
docker-compose up -d

# Check logs
docker-compose logs -f nats

# Access NATS CLI
docker-compose exec nats-box nats --help
```

### Option 3: NixOS VM (Production-like - 15 minutes)

Create `nats-vm.nix`:
```nix
{ config, pkgs, lib, ... }:

{
  # VM Configuration
  virtualisation = {
    cores = 2;
    memorySize = 2048;
    diskSize = 10240;
    
    # Forward NATS ports
    forwardPorts = [
      { from = "host"; host.port = 4222; guest.port = 4222; }
      { from = "host"; host.port = 8222; guest.port = 8222; }
      { from = "host"; host.port = 6222; guest.port = 6222; }
    ];
  };

  # NATS Server
  services.nats = {
    enable = true;
    package = pkgs.nats-server;
    
    settings = {
      server_name = "cim-nats-vm";
      listen = "0.0.0.0:4222";
      monitor_port = 8222;
      
      # JetStream Configuration
      jetstream = {
        store_dir = "/var/lib/nats/jetstream";
        max_memory_store = "512MB";
        max_file_store = "2GB";
        
        # Streams configuration
        streams = [
          {
            name = "EVENTS";
            subjects = ["event.>"];
            retention = "limits";
            max_msgs = 1000000;
            max_age = "7d";
            storage = "file";
            replicas = 1;
          }
          {
            name = "COMMANDS";
            subjects = ["cmd.>"];
            retention = "interest";
            max_age = "1h";
            storage = "memory";
            replicas = 1;
          }
        ];
      };
      
      # Clustering (optional)
      cluster = {
        name = "cim-cluster";
        listen = "0.0.0.0:6222";
        
        # Add other nodes here for clustering
        routes = [
          # "nats://node2:6222"
          # "nats://node3:6222"
        ];
      };
      
      # Authorization (optional)
      authorization = {
        users = [
          {
            user = "admin";
            password = "$2a$11$W2zko751KUvVy59mUTWmpOdWjpEm5qhcCZRd05GjI/sSOT.xtiHyG"; # "changeme"
            permissions = {
              publish = ">";
              subscribe = ">";
            };
          }
          {
            user = "client";
            password = "$2a$11$W2zko751KUvVy59mUTWmpOdWjpEm5qhcCZRd05GjI/sSOT.xtiHyG"; # "changeme"
            permissions = {
              publish = ["cmd.>", "event.>"];
              subscribe = ["event.>", "_INBOX.>"];
            };
          }
        ];
      };
      
      # Logging
      debug = false;
      trace = false;
      logtime = true;
      
      # Limits
      max_connections = 1000;
      max_payload = "1MB";
      max_pending = "64MB";
      
      # TLS (optional)
      # tls = {
      #   cert_file = "/etc/nats/certs/server.crt";
      #   key_file = "/etc/nats/certs/server.key";
      # };
    };
  };

  # Firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 4222 6222 8222 ];
  };

  # System packages
  environment.systemPackages = with pkgs; [
    nats-cli
    natscli
    vim
    htop
  ];

  # Create systemd service for initialization
  systemd.services.nats-init = {
    description = "Initialize NATS JetStream";
    after = [ "nats.service" ];
    requires = [ "nats.service" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "nats-init" ''
        # Wait for NATS to be ready
        sleep 5
        
        # Create streams
        ${pkgs.natscli}/bin/nats stream add EVENTS \
          --subjects "event.>" \
          --retention limits \
          --max-msgs=1000000 \
          --max-age=7d \
          --storage file \
          --replicas 1 \
          --no-allow-rollup \
          --discard old \
          --dupe-window 2m
          
        ${pkgs.natscli}/bin/nats stream add COMMANDS \
          --subjects "cmd.>" \
          --retention interest \
          --max-age=1h \
          --storage memory \
          --replicas 1
          
        echo "NATS JetStream initialized"
      '';
    };
  };
}
```

Build and run the VM:
```bash
# Build the VM
nix-build '<nixpkgs/nixos>' -A vm -I nixos-config=./nats-vm.nix

# Run the VM
./result/bin/run-*-vm

# SSH into VM (after it boots)
ssh -p 2222 root@localhost
```

### Option 4: Local Development (10 minutes)

Using Nix:
```bash
# Enter development shell
nix develop

# Or install directly
nix-env -iA nixpkgs.nats-server

# Start NATS with JetStream
nats-server -js -sd ./nats-data -m 8222

# In another terminal, configure streams
nats stream add EVENTS \
  --subjects "event.>" \
  --retention limits \
  --max-msgs=1000000 \
  --storage file
```

## 📊 Monitoring Dashboard

Access the monitoring dashboard at: http://localhost:8222

Key endpoints:
- `/healthz` - Health check
- `/varz` - General server info
- `/jsz` - JetStream info
- `/connz` - Connection details
- `/routez` - Cluster routes
- `/subsz` - Subscriptions

## 🔧 JetStream Configuration

### Create Event Stream
```bash
nats stream add EVENTS \
  --subjects "event.>" \
  --retention limits \
  --max-msgs=1000000 \
  --max-age=7d \
  --storage file \
  --replicas 1 \
  --discard old \
  --dupe-window 2m
```

### Create Command Stream
```bash
nats stream add COMMANDS \
  --subjects "cmd.>" \
  --retention interest \
  --max-age=1h \
  --storage memory \
  --replicas 1
```

### Create Projection Stream
```bash
nats stream add PROJECTIONS \
  --subjects "projection.>" \
  --retention limits \
  --max-msgs-per-subject=1 \
  --storage file \
  --replicas 1 \
  --allow-rollup
```

## 🔐 Security Configuration

### Basic Authentication
```yaml
# nats.conf
authorization {
  users = [
    {user: admin, password: $2a$11$W2zko751KUvVy59mUTWmpOdWjpEm5qhcCZRd05GjI/sSOT.xtiHyG}
    {user: client, password: $2a$11$W2zko751KUvVy59mUTWmpOdWjpEm5qhcCZRd05GjI/sSOT.xtiHyG}
  ]
}
```

Generate password hash:
```bash
nats server passwd -p "your-password"
```

### TLS Configuration
```yaml
# nats.conf
tls {
  cert_file: "/etc/nats/certs/server.crt"
  key_file: "/etc/nats/certs/server.key"
  ca_file: "/etc/nats/certs/ca.crt"
  verify: true
}
```

## 🌐 Clustering Setup

### 3-Node Cluster
```yaml
# Node 1 (nats1.conf)
server_name: nats-1
listen: 0.0.0.0:4222
cluster {
  name: cim-cluster
  listen: 0.0.0.0:6222
  routes = [
    nats://nats2:6222
    nats://nats3:6222
  ]
}

# Node 2 (nats2.conf)
server_name: nats-2
listen: 0.0.0.0:4222
cluster {
  name: cim-cluster
  listen: 0.0.0.0:6222
  routes = [
    nats://nats1:6222
    nats://nats3:6222
  ]
}

# Node 3 (nats3.conf)
server_name: nats-3
listen: 0.0.0.0:4222
cluster {
  name: cim-cluster
  listen: 0.0.0.0:6222
  routes = [
    nats://nats1:6222
    nats://nats2:6222
  ]
}
```

## 🧪 Testing Your Setup

### Test Basic Connectivity
```bash
# Publish a test message
nats pub test.subject "Hello NATS"

# Subscribe to test messages
nats sub "test.>"

# Request-Reply test
nats reply test.service "I can help"
nats request test.service "Help me" --timeout=1s
```

### Test JetStream
```bash
# Publish to stream
nats pub event.test '{"type":"TestEvent","data":"test"}'

# Read from stream
nats stream view EVENTS

# Create consumer
nats consumer add EVENTS TEST \
  --filter "event.test" \
  --ack explicit \
  --deliver all \
  --replay instant
```

### Test with Your Application
```rust
use async_nats;

#[tokio::main]
async fn main() -> Result<(), async_nats::Error> {
    // Connect to NATS
    let client = async_nats::connect("nats://localhost:4222").await?;
    
    // Get JetStream context
    let jetstream = async_nats::jetstream::new(client);
    
    // Publish event
    jetstream
        .publish("event.order.created", r#"{"order_id":"123"}"#.into())
        .await?;
    
    println!("Event published!");
    Ok(())
}
```

## 📈 Performance Tuning

### Memory Settings
```yaml
jetstream {
  max_memory_store: 1GB
  max_file_store: 10GB
}
```

### Connection Limits
```yaml
max_connections: 10000
max_payload: 1MB
max_pending: 64MB
max_control_line: 4KB
```

### Write Performance
```yaml
jetstream {
  sync_interval: 30s  # How often to sync to disk
  sync_always: false  # Don't sync on every write
}
```

## 🔍 Troubleshooting

### Common Issues

**Cannot connect to NATS**
```bash
# Check if NATS is running
docker ps | grep nats
ps aux | grep nats-server

# Check ports
netstat -tlnp | grep 4222

# Test connection
telnet localhost 4222
```

**JetStream not enabled**
```bash
# Check JetStream status
nats server report jetstream

# Enable JetStream
nats-server -js
```

**Stream not found**
```bash
# List streams
nats stream list

# Create missing stream
nats stream add EVENTS --subjects "event.>"
```

**Permission denied**
```bash
# Check user permissions
nats server report connections

# Update user permissions in config
```

## 📚 Resources

- [NATS Documentation](https://docs.nats.io/)
- [JetStream Documentation](https://docs.nats.io/jetstream)
- [NATS CLI Cheat Sheet](https://docs.nats.io/using-nats/nats-tools/nats_cli)
- [NATS by Example](https://natsbyexample.com/)

## 🎯 Next Steps

1. ✅ NATS is running
2. ✅ JetStream is enabled
3. ✅ Streams are created
4. → Start building your domain
5. → Publish your first events
6. → Create projections
7. → Test end-to-end