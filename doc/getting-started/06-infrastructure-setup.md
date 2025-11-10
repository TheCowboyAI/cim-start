# Step 6: Infrastructure-First Setup

**Time Required**: 4-5 weeks

**Prerequisites**:
- [Step 1: Clone and Initialize](01-clone-and-initialize.md) ✅
- [Step 2: Define Purpose](02-define-purpose.md) ✅
- [Step 3: Create Organization](03-create-organization.md) ✅
- [Step 4: Add People](04-add-people.md) ✅
- [Step 5: Choose Your Path](05-choose-your-path.md) - **Chose Path B** ✅

---

**Note**: This guide is for the **Infrastructure-First** path. If you chose Domain-First, see [Domain Development Guide](06-domain-development.md) instead.

---

## Overview of Infrastructure-First Workflow

### What Does Infrastructure-First Mean?

Infrastructure-First means deploying your production NATS cluster, PKI, and security infrastructure BEFORE developing domain models. You're building the foundation before constructing the house.

Think of it like laying a robust electrical grid before building neighborhoods. The power infrastructure exists, tested, and ready - then you build homes and businesses that plug into it.

### Why Start with Infrastructure?

1. **Production-Ready from Day One**: Domain code runs on production infrastructure immediately
2. **Real-World Testing**: Discover infrastructure issues before domain complexity adds confusion
3. **Team Scalability**: Infrastructure and domain teams can work in parallel
4. **Enterprise Compliance**: Security team can validate PKI and network topology early
5. **No Migration**: Domain never moves between environments

### What Will You Accomplish?

By the end of this step, you'll have:
- Production NATS cluster (3+ nodes) deployed and operational
- Complete PKI infrastructure in cim-keys repository
- TLS-encrypted, JWT-authenticated messaging infrastructure
- Verified JetStream persistence and replication
- Ready-to-use production environment for domain development

---

## Phase 1: Infrastructure Planning (Week 1)

### 1.1 Define Network Topology

**Determine your deployment model**:

```yaml
# infrastructure-plan.yaml
infrastructure:
  topology: "cluster"  # Options: leaf, cluster, super-cluster

  # For cluster (3+ nodes):
  nodes:
    - name: "nats-1"
      ip: "10.0.0.41"
      role: "cluster-member"
      hardware: "Proxmox LXC, 4GB RAM, 2 vCPU"

    - name: "nats-2"
      ip: "10.0.0.42"
      role: "cluster-member"
      hardware: "Proxmox LXC, 4GB RAM, 2 vCPU"

    - name: "nats-3"
      ip: "10.0.0.43"
      role: "cluster-member"
      hardware: "Proxmox LXC, 4GB RAM, 2 vCPU"

  storage:
    - name: "cimstor"
      ip: "172.16.0.2"
      purpose: "IPLD object store + NATS leaf"
      storage: "2TB NVMe"

  network:
    primary_vlan: "10.0.0.0/24"
    storage_vlan: "172.16.0.0/24"
    gateway: "10.0.0.1"  # UniFi Dream Machine Pro
```

**SAGE Command**:
```bash
@sage Create infrastructure topology for [cluster size] nodes
```

### 1.2 Resource Requirements

**Minimum per NATS node**:
- **CPU**: 2 cores (4 recommended)
- **RAM**: 4GB (8GB recommended for JetStream)
- **Storage**: 50GB (varies with JetStream retention)
- **Network**: 1Gbps (10Gbps for high throughput)

**For 3-node cluster**:
- Total: 6-12 cores, 12-24GB RAM, 150GB+ storage
- Plus: IPLD object store node (cimstor)

### 1.3 Deployment Platform

**Options**:

1. **Proxmox LXC** (Current deployed approach)
   - Lightweight containers on Proxmox VE
   - NixOS-based containers
   - Reference: 10.0.0.41-43 deployment

2. **Bare Metal NixOS** (Future approach)
   - Direct NixOS installation
   - No virtualization overhead
   - Requires dedicated hardware

3. **Cloud (AWS/GCP/Azure)**
   - VM-based deployment
   - Use NixOS AMIs/images
   - Higher cost, easier scaling

**SAGE Command**:
```bash
@sage Which deployment platform should I use for [my requirements]?
```

---

## Phase 2: Setup cim-keys Repository (Week 2)

### 2.1 Create cim-keys Repository

**Why separate repository?**
- Private credentials separate from public code
- Different access controls (ops team only)
- Independent versioning and audit trail

```bash
# Create private repository
cd ..
git init cim-keys
cd cim-keys

# Initial structure
mkdir -p {nsc,operators,accounts,users,certs,docs}

# Create README
cat > README.md <<'EOF'
# CIM Keys - PKI and Security Credentials

**PRIVATE REPOSITORY - DO NOT SHARE**

This repository contains all PKI credentials for our CIM infrastructure:
- NSC operators, accounts, and users
- TLS certificates and keys
- JWT authentication tokens
- Encryption keys

## Structure
- `nsc/` - NATS Security (NSC) keys and JWTs
- `operators/` - Operator-level credentials
- `accounts/` - Account-level credentials
- `users/` - User/service credentials
- `certs/` - TLS certificates
- `docs/` - Key management documentation
EOF

git add .
git commit -m "chore: Initialize cim-keys repository"
```

**SAGE Command**:
```bash
@sage Initialize cim-keys repository for [organization name]
```

### 2.2 Install NSC (NATS Security CLI)

```bash
# Using Nix (recommended)
nix develop

# NSC should be available in development shell
nsc --version

# If not, add to your flake.nix:
# buildInputs = [ pkgs.nsc ];
```

### 2.3 Create Operator

The **Operator** is the root of trust in NATS security hierarchy.

```bash
cd cim-keys

# Create operator (replace with your org name)
nsc add operator thecowboyai

# Operator JWT created at:
# ~/.nsc/nats/thecowboyai/thecowboyai.jwt

# Copy to cim-keys
mkdir -p operators/thecowboyai
cp ~/.nsc/nats/thecowboyai/thecowboyai.jwt operators/thecowboyai/

# Operator signing key (KEEP PRIVATE!)
cp ~/.nkeys/keys/O/*/*.nk operators/thecowboyai/operator.nk

# Commit
git add operators/
git commit -m "feat: Add thecowboyai operator"
```

**SAGE Command**:
```bash
@sage Create NATS operator for [organization name]
```

### 2.4 Create Accounts

**Accounts** provide isolation boundaries. Common patterns:

```bash
# System account (for infrastructure services)
nsc add account SYSTEM

# Domain accounts (one per bounded context or business domain)
nsc add account MORTGAGE_UNDERWRITING
nsc add account ORGANIZATION
nsc add account PEOPLE

# Copy JWTs and keys
for account in SYSTEM MORTGAGE_UNDERWRITING ORGANIZATION PEOPLE; do
    mkdir -p accounts/$account
    cp ~/.nsc/nats/thecowboyai/accounts/$account/$account.jwt accounts/$account/
    cp ~/.nkeys/keys/A/*/$account.nk accounts/$account/account.nk
done

git add accounts/
git commit -m "feat: Add domain accounts"
```

**SAGE Command**:
```bash
@sage Create NATS accounts for [list of domains]
```

### 2.5 Create Users

**Users** are service identities with specific permissions.

```bash
# Infrastructure services
nsc add user -a SYSTEM nats-box
nsc add user -a SYSTEM noc-dashboard

# Domain services
nsc add user -a MORTGAGE_UNDERWRITING underwriting-service
nsc add user -a ORGANIZATION org-service
nsc add user -a PEOPLE person-service

# Developers (for testing)
nsc add user -a SYSTEM developer

# Copy credentials
for account in SYSTEM MORTGAGE_UNDERWRITING ORGANIZATION PEOPLE; do
    for user in $(nsc list users -a $account | grep -v "Users:" | awk '{print $1}'); do
        mkdir -p users/$account/$user
        nsc generate creds -a $account -n $user > users/$account/$user/$user.creds
    done
done

git add users/
git commit -m "feat: Add service and user credentials"
```

**SAGE Command**:
```bash
@sage Create NATS users for [services and people]
```

### 2.6 Configure Permissions

Define subject-level permissions:

```bash
# Edit account with permissions
nsc edit account MORTGAGE_UNDERWRITING

# Add permissions interactively, or use YAML:
cat > accounts/MORTGAGE_UNDERWRITING/permissions.yaml <<'EOF'
permissions:
  publish:
    allow:
      - "thecowboyai.mortgage.>"
      - "thecowboyai.person.query"
  subscribe:
    allow:
      - "thecowboyai.mortgage.>"
      - "thecowboyai.person.events.>"
  deny:
    - "thecowboyai.system.>"
EOF

# Apply permissions via NSC
# (See NSC documentation for detailed permission management)
```

### 2.7 Push to Remote

```bash
# Add remote (create private repo first)
git remote add origin git@github.com:yourusername/cim-keys.git

# Push
git push -u origin main
```

---

## Phase 3: Deploy NATS Cluster (Week 3)

### 3.1 Prepare Deployment Environment

**For Proxmox LXC**:

```bash
# On Proxmox host (pve1, pve2, pve3)
# Create LXC containers with NixOS template

# Example for nats-1 on pve1:
pct create 201 \
  local:vztmpl/nixos-23.11-x86_64.tar.xz \
  --hostname nats-1 \
  --memory 4096 \
  --cores 2 \
  --net0 name=eth0,bridge=vmbr0,ip=10.0.0.41/24,gw=10.0.0.1 \
  --storage local-lvm \
  --rootfs local-lvm:20

# Repeat for nats-2 (202 on pve2) and nats-3 (203 on pve3)
```

**SAGE Command**:
```bash
@sage Generate Proxmox LXC creation commands for [topology]
```

### 3.2 Deploy NATS Configuration

Create NixOS configuration for each node:

```nix
# nats-cluster-config.nix
{ config, pkgs, lib, ... }:

{
  # Enable NATS
  services.nats = {
    enable = true;

    # Server configuration
    serverConfig = ''
      port: 4222
      http_port: 8222

      # Cluster configuration
      cluster {
        name: "thecowboyai"
        port: 6222

        routes: [
          nats://10.0.0.41:6222
          nats://10.0.0.42:6222
          nats://10.0.0.43:6222
        ]
      }

      # JetStream
      jetstream {
        store_dir: "/var/lib/nats/jetstream"
        max_memory_store: 2G
        max_file_store: 10G
      }

      # Security - reference cim-keys
      operator: "/etc/nats/creds/operator.jwt"
      resolver: URL(nats://10.0.0.41:4222)

      # TLS (will add in Phase 4)
    '';
  };

  # Firewall
  networking.firewall.allowedTCPPorts = [ 4222 6222 8222 ];

  # Storage
  fileSystems."/var/lib/nats" = {
    device = "/dev/mapper/nats-data";
    fsType = "ext4";
  };
}
```

**SAGE Command**:
```bash
@sage Generate NixOS configuration for [cluster topology]
```

### 3.3 Deploy to Nodes

```bash
# From your development machine
# Copy configuration to each node

for node in nats-1 nats-2 nats-3; do
    # Copy NixOS configuration
    scp nats-cluster-config.nix root@$node:/etc/nixos/nats.nix

    # Copy operator JWT from cim-keys
    scp ../cim-keys/operators/thecowboyai/thecowboyai.jwt root@$node:/etc/nats/creds/operator.jwt

    # Rebuild NixOS
    ssh root@$node "nixos-rebuild switch"
done
```

**SAGE Command**:
```bash
@sage Deploy NATS configuration to [node list]
```

### 3.4 Verify Cluster Formation

```bash
# Check cluster status from any node
nats --server nats://10.0.0.41:4222 server list

# Expected output:
# ┌────────────────────────────────────────────────────────┐
# │                   Server Information                    │
# ├──────────┬─────────────┬──────┬─────────┬─────────────┤
# │ Name     │ Cluster     │ Host │ Version │ Connections │
# ├──────────┼─────────────┼──────┼─────────┼─────────────┤
# │ nats-1   │ thecowboyai │ 41   │ 2.10.7  │ 2           │
# │ nats-2   │ thecowboyai │ 42   │ 2.10.7  │ 2           │
# │ nats-3   │ thecowboyai │ 43   │ 2.10.7  │ 2           │
# └──────────┴─────────────┴──────┴─────────┴─────────────┘

# Check JetStream
nats --server nats://10.0.0.41:4222 stream list

# Create test stream
nats stream add TEST --subjects "test.>" --storage file --replicas 3
```

**SAGE Command**:
```bash
@sage Verify NATS cluster health for [cluster name]
```

---

## Phase 4: Configure Security (Week 3-4)

### 4.1 Generate TLS Certificates

**Using Let's Encrypt** (if public DNS):
```bash
# Install certbot
nix-shell -p certbot

# Generate certificates
certbot certonly --standalone \
  -d nats-1.yourdomain.com \
  -d nats-2.yourdomain.com \
  -d nats-3.yourdomain.com

# Copy to cim-keys
mkdir -p cim-keys/certs/letsencrypt
cp /etc/letsencrypt/live/nats-*.yourdomain.com/* cim-keys/certs/letsencrypt/
```

**Using self-signed** (for private networks):
```bash
# Generate CA
openssl req -x509 -newkey rsa:4096 \
  -keyout cim-keys/certs/ca-key.pem \
  -out cim-keys/certs/ca-cert.pem \
  -days 3650 -nodes \
  -subj "/CN=TheCowboyAI CA"

# Generate server certificates
for node in nats-1 nats-2 nats-3; do
    openssl req -newkey rsa:4096 -nodes \
      -keyout cim-keys/certs/$node-key.pem \
      -out cim-keys/certs/$node-req.pem \
      -subj "/CN=$node.thecowboyai.internal"

    openssl x509 -req \
      -in cim-keys/certs/$node-req.pem \
      -CA cim-keys/certs/ca-cert.pem \
      -CAkey cim-keys/certs/ca-key.pem \
      -CAcreateserial \
      -out cim-keys/certs/$node-cert.pem \
      -days 365
done

cd cim-keys
git add certs/
git commit -m "feat: Add TLS certificates"
git push
```

**SAGE Command**:
```bash
@sage Generate TLS certificates for [cluster nodes]
```

### 4.2 Configure TLS in NATS

Update NATS configuration:

```nix
# Add to nats-cluster-config.nix
serverConfig = ''
  # ... previous config ...

  tls {
    cert_file: "/etc/nats/certs/server-cert.pem"
    key_file: "/etc/nats/certs/server-key.pem"
    ca_file: "/etc/nats/certs/ca-cert.pem"
    verify: true
    timeout: 5
  }
'';
```

Deploy certificates and reload:

```bash
for node in nats-1 nats-2 nats-3; do
    # Copy certificates
    scp ../cim-keys/certs/$node-cert.pem root@$node:/etc/nats/certs/server-cert.pem
    scp ../cim-keys/certs/$node-key.pem root@$node:/etc/nats/certs/server-key.pem
    scp ../cim-keys/certs/ca-cert.pem root@$node:/etc/nats/certs/ca-cert.pem

    # Reload NATS
    ssh root@$node "systemctl reload nats"
done
```

### 4.3 Configure JWT Authentication

Update NATS to use account resolver:

```nix
serverConfig = ''
  # ... previous config ...

  operator: "/etc/nats/creds/operator.jwt"

  resolver: {
    type: full
    dir: "/var/lib/nats/jwt"
    allow_delete: false
    interval: "2m"
  }
'';
```

Push account JWTs to resolver:

```bash
# For each account
for account in SYSTEM MORTGAGE_UNDERWRITING ORGANIZATION PEOPLE; do
    nsc push -a $account --system-account SYSTEM
done
```

### 4.4 Test Authentication

```bash
# Try without credentials (should fail)
nats --server nats://10.0.0.41:4222 pub test "hello"
# Error: Authorization Violation

# Try with credentials (should succeed)
nats --server nats://10.0.0.41:4222 \
     --creds ../cim-keys/users/SYSTEM/developer/developer.creds \
     pub test "hello"
# Published 5 bytes to "test"
```

---

## Phase 5: Verify Deployment (Week 4)

### 5.1 Health Checks

Create verification script:

```bash
#!/usr/bin/env bash
# verify-cluster.sh

echo "=== NATS Cluster Health Check ==="

# Check all nodes are reachable
for node in 10.0.0.41 10.0.0.42 10.0.0.43; do
    echo "Checking nats://$node:4222..."
    curl -s http://$node:8222/varz | jq -r '.server_name, .cluster.name, .jetstream.config.max_memory, .jetstream.config.max_storage'
done

# Check cluster connectivity
echo ""
echo "=== Cluster Routes ==="
nats --server nats://10.0.0.41:4222 \
     --creds ../cim-keys/users/SYSTEM/developer/developer.creds \
     server list

# Check JetStream replication
echo ""
echo "=== JetStream Streams ==="
nats --server nats://10.0.0.41:4222 \
     --creds ../cim-keys/users/SYSTEM/developer/developer.creds \
     stream list

# Test event persistence
echo ""
echo "=== Event Persistence Test ==="
nats --server nats://10.0.0.41:4222 \
     --creds ../cim-keys/users/SYSTEM/developer/developer.creds \
     stream add HEALTH_CHECK \
     --subjects "health.>" \
     --storage file \
     --replicas 3

# Publish test events
for i in {1..10}; do
    nats --server nats://10.0.0.41:4222 \
         --creds ../cim-keys/users/SYSTEM/developer/developer.creds \
         pub health.test "Test event $i"
done

# Verify persistence
nats --server nats://10.0.0.41:4222 \
     --creds ../cim-keys/users/SYSTEM/developer/developer.creds \
     stream info HEALTH_CHECK

echo ""
echo "=== Health Check Complete ==="
```

**SAGE Command**:
```bash
@sage Generate health check script for [cluster]
@sage Run health checks on [cluster]
```

### 5.2 Performance Testing

```bash
# Install nats-bench
nix-shell -p nats-server

# Run benchmark
nats bench test.performance \
  --server nats://10.0.0.41:4222 \
  --creds ../cim-keys/users/SYSTEM/developer/developer.creds \
  --pub 3 \
  --sub 3 \
  --msgs 100000 \
  --size 256

# Expected results for 3-node cluster:
# Pub stats: 50,000+ msgs/sec
# Sub stats: 150,000+ msgs/sec (3 subscribers)
```

### 5.3 Failover Testing

```bash
# Stop one node
ssh root@nats-2 "systemctl stop nats"

# Verify cluster still operational
nats --server nats://10.0.0.41:4222 \
     --creds ../cim-keys/users/SYSTEM/developer/developer.creds \
     server list
# Should show 2 nodes

# Verify JetStream still available (with R3 replication)
nats --server nats://10.0.0.41:4222 \
     --creds ../cim-keys/users/SYSTEM/developer/developer.creds \
     stream info HEALTH_CHECK
# Should show 2/3 replicas

# Restart node
ssh root@nats-2 "systemctl start nats"

# Verify rejoin
nats --server nats://10.0.0.41:4222 \
     --creds ../cim-keys/users/SYSTEM/developer/developer.creds \
     server list
# Should show 3 nodes
```

### 5.4 Monitoring Setup

Deploy monitoring dashboard:

```bash
# Use nats-surveyor or Prometheus + Grafana
# See: https://github.com/nats-io/nats-surveyor

# Example Prometheus scrape config:
cat > monitoring/prometheus.yml <<'EOF'
scrape_configs:
  - job_name: 'nats'
    static_configs:
      - targets:
        - '10.0.0.41:7777'
        - '10.0.0.42:7777'
        - '10.0.0.43:7777'
EOF
```

---

## Phase 6: Return to Domain Development (Week 5+)

### 6.1 Your Infrastructure is Ready

You now have:
- ✅ Production NATS cluster (3 nodes, clustered)
- ✅ TLS encryption for all connections
- ✅ JWT authentication with NSC-managed credentials
- ✅ JetStream persistence with R3 replication
- ✅ Failover tested and verified
- ✅ Monitoring and health checks operational

**Next**: Develop your domain models ON production infrastructure.

### 6.2 Domain Development Workflow

With infrastructure ready, you can now:

**1. Define Domain Purpose** (Already done in Step 2)
   - purpose.yaml defines your domain

**2. Event Storm and Model**
   - Run event storming sessions
   - Identify aggregates, events, commands
   - Define bounded contexts

**3. Implement Domain Code**
   - Use cim-domain library
   - Create aggregates with phantom-typed IDs
   - Implement event sourcing

**4. Deploy to Production**
   - Domain services connect to NATS cluster
   - Use credentials from cim-keys
   - Publish/subscribe on authorized subjects

**5. Iterate**
   - Monitor via NATS streams
   - Refine domain model
   - Scale horizontally by adding services

### 6.3 Example: Deploy Person Service

```rust
// person-service/src/main.rs
use async_nats;
use cim_domain::EventStore;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Connect to production NATS cluster
    let client = async_nats::ConnectOptions::with_credentials_file(
        "../cim-keys/users/PEOPLE/person-service/person-service.creds"
    )?
    .connect("nats://10.0.0.41:4222,nats://10.0.0.42:4222,nats://10.0.0.43:4222")
    .await?;

    let jetstream = async_nats::jetstream::new(client);

    // Create event store
    let event_store = EventStore::new(jetstream, "PEOPLE").await?;

    // Your domain logic here
    // ...

    Ok(())
}
```

**SAGE Command**:
```bash
@sage Generate domain service template for [domain name]
```

---

## Infrastructure Management

### Day 2 Operations

**Configuration Updates**:
```bash
# Edit configuration in cim repository
vim domains/network-infrastructure/nats-cluster/nats-cluster-config.nix

# Deploy to cluster
./domains/network-infrastructure/nats-cluster/deploy-config-update.sh
```

**Credential Rotation**:
```bash
# Rotate user credentials (example)
cd ../cim-keys
nsc revoke user -a PEOPLE -n person-service
nsc add user -a PEOPLE person-service
nsc generate creds -a PEOPLE -n person-service > users/PEOPLE/person-service/person-service.creds

git add .
git commit -m "security: Rotate person-service credentials"
git push

# Update running services with new credentials
```

**Scaling**:
```bash
# Add 4th node to cluster
# 1. Create new LXC container (nats-4 at 10.0.0.44)
# 2. Update nats-cluster-config.nix routes
# 3. Deploy configuration to all nodes
# 4. Verify cluster membership
```

**Backup**:
```bash
# Backup JetStream data
for node in nats-1 nats-2 nats-3; do
    ssh root@$node "tar czf /tmp/jetstream-backup.tar.gz /var/lib/nats/jetstream"
    scp root@$node:/tmp/jetstream-backup.tar.gz backups/$node-$(date -I).tar.gz
done

# Backup cim-keys (already in git, but create offline copy)
cd ../cim-keys
git archive --format=tar.gz --output=../cim-keys-backup-$(date -I).tar.gz HEAD
gpg --encrypt --recipient ops@thecowboyai.com ../cim-keys-backup-$(date -I).tar.gz
```

---

## Troubleshooting

### Cluster Won't Form
```bash
# Check network connectivity
for node in 10.0.0.41 10.0.0.42 10.0.0.43; do
    ping -c 3 $node
done

# Check cluster port (6222)
for node in 10.0.0.41 10.0.0.42 10.0.0.43; do
    nc -zv $node 6222
done

# Check NATS logs
ssh root@nats-1 "journalctl -u nats -n 100"
```

### Authentication Failures
```bash
# Verify JWT is pushed to resolver
nsc pull -a PEOPLE

# Verify credentials file format
cat ../cim-keys/users/PEOPLE/person-service/person-service.creds
# Should contain:
# -----BEGIN NATS USER JWT-----
# ...
# -----END NATS USER JWT-----
#
# ************************* IMPORTANT *************************
# NKEY Seed printed below can be used to sign and prove identity.
# ...

# Test authentication
nats --server nats://10.0.0.41:4222 \
     --creds ../cim-keys/users/PEOPLE/person-service/person-service.creds \
     rtt
```

### JetStream Issues
```bash
# Check JetStream status
curl -s http://10.0.0.41:8222/jsz | jq

# Verify storage limits
nats --server nats://10.0.0.41:4222 \
     --creds ../cim-keys/users/SYSTEM/developer/developer.creds \
     server report jetstream

# Check stream health
nats --server nats://10.0.0.41:4222 \
     --creds ../cim-keys/users/SYSTEM/developer/developer.creds \
     stream info [STREAM_NAME]
```

---

## SAGE Commands Summary

```bash
# Planning Phase
@sage Create infrastructure topology for [cluster size] nodes
@sage Which deployment platform should I use?

# PKI Phase
@sage Initialize cim-keys repository
@sage Create NATS operator for [org name]
@sage Create NATS accounts for [domains]
@sage Create NATS users for [services]

# Deployment Phase
@sage Generate Proxmox LXC creation commands
@sage Generate NixOS configuration for [topology]
@sage Deploy NATS configuration to [nodes]
@sage Verify NATS cluster health

# Security Phase
@sage Generate TLS certificates for [nodes]

# Verification Phase
@sage Generate health check script
@sage Run health checks
```

---

## Next Steps

✅ You've deployed production NATS infrastructure
✅ You've established PKI in cim-keys
✅ You've verified cluster health and security
✅ You're ready for domain development

**Next Step**: [Step 7: Deployment →](07-deployment.md)

In Step 7, you'll:
- Deploy your domain services to the NATS cluster
- Configure service accounts and permissions
- Setup monitoring and observability
- Establish operational procedures

---

**Remember**: In Infrastructure-First, we build the cathedral before painting the ceiling.
