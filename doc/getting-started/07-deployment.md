# Step 7: Deployment

**Time Required**: 1-2 weeks

**Prerequisites**:
- [Step 1: Clone and Initialize](01-clone-and-initialize.md) ✅
- [Step 2: Define Purpose](02-define-purpose.md) ✅
- [Step 3: Create Organization](03-create-organization.md) ✅
- [Step 4: Add People](04-add-people.md) ✅
- [Step 5: Choose Your Path](05-choose-your-path.md) ✅
- **Either**:
  - [Step 6a: Domain Development](06-domain-development.md) ✅ (Domain-First)
  - [Step 6b: Infrastructure Setup](06-infrastructure-setup.md) ✅ (Infrastructure-First)

---

## Overview

By this step, you have:
- **Domain-First Path**: Validated domain model, tested with local NATS, ready for production infrastructure
- **Infrastructure-First Path**: Production NATS cluster deployed, domain services ready to deploy

Now we bring it all together into a **production CIM deployment**.

---

## Deployment Topology Decisions

### Starting Point: Single Leaf Node (Recommended)

**The Mac Studio M4 Ultra is our recommended starting point:**
- **Hardware**: Mac Studio M4 Ultra with 512GB RAM (or better)
- **OS**: macOS with nix-darwin
- **Role**: Single leaf node running NATS + all domain services
- **Capacity**: Handles significant load for most business domains
- **Cost**: $7,200-8,000 (one-time purchase)
- **Benefits**:
  - Silent, efficient, powerful
  - Perfect for office deployment
  - No data center needed initially
  - Easy to manage for small teams

**What is a Leaf Node?**
A leaf node is a **single server** that:
- Runs NATS server with JetStream
- Hosts all your domain services
- Can optionally connect to a cluster later
- Provides complete CIM functionality standalone

### Scaling Path

```
Start Here → Single Leaf Node (Mac Studio M4 Ultra)
             └─ Mac Studio with 512GB RAM, NATS + domain services
             └─ Capacity: 10,000+ events/sec, 100+ concurrent users
             └─ Cost: ~$8,000 one-time

Scale to → NATS Cluster (3+ nodes)
           ├─ Self-Hosted: 3 Mac Studios or servers
           │  └─ Total cost: ~$24,000 + networking
           └─ Cloud-Hosted: AWS/GCP/Azure VMs
              └─ Cost: ~$500-2,000/month

Scale to → Super-Cluster (3+ clusters)
           └─ Global distribution, multi-region
           └─ Enterprise-scale deployment
```

---

## Part 1: Single Leaf Node Deployment (Mac Studio)

### 1.1 Hardware Setup

**Mac Studio M4 Ultra - Recommended Specs:**
- **Processor**: M4 Ultra chip (24-core CPU)
- **RAM**: 512GB unified memory (minimum recommended)
- **Storage**: 2TB SSD (minimum), 4TB+ recommended
- **Network**: 10Gb Ethernet
- **Power**: Uninterruptible Power Supply (UPS) recommended

**Why these specs?**
- 512GB RAM: Supports large JetStream stores, many concurrent services
- 2TB+ SSD: Fast event persistence, room for growth
- 10Gb Ethernet: High-throughput event streaming
- M4 Ultra: Efficient, powerful, handles significant concurrent load

**Alternative Hardware:**
If Mac Studio isn't available:
- High-end Linux server (e.g., Dell PowerEdge R750)
- AMD EPYC or Intel Xeon processors
- Similar RAM and storage specs
- NixOS instead of nix-darwin

### 1.2 Install nix-darwin

```bash
# Install Nix package manager on macOS
sh <(curl -L https://nixos.org/nix/install)

# Install nix-darwin
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
./result/bin/darwin-installer

# Enable flakes
mkdir -p ~/.config/nix
cat > ~/.config/nix/nix.conf <<EOF
experimental-features = nix-command flakes
EOF
```

### 1.3 Configure System

Create your CIM leaf node configuration:

```nix
# /etc/nixos/darwin-configuration.nix
{ config, pkgs, ... }:

{
  # Enable nix-darwin
  services.nix-daemon.enable = true;

  # Install required packages
  environment.systemPackages = with pkgs; [
    nats-server    # NATS server
    natscli        # NATS CLI tools
    nsc            # NATS Security CLI
    docker         # For containerized services
    git
    vim
  ];

  # NATS service configuration
  launchd.daemons.nats = {
    script = ''
      ${pkgs.nats-server}/bin/nats-server \
        --config /usr/local/etc/nats/nats.conf
    '';
    serviceConfig = {
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/var/log/nats.log";
      StandardErrorPath = "/var/log/nats.error.log";
    };
  };

  # Firewall configuration
  # (macOS firewall configured separately via System Preferences)
}
```

### 1.4 Configure NATS

```bash
# Create NATS configuration directory
sudo mkdir -p /usr/local/etc/nats

# Create NATS configuration
sudo tee /usr/local/etc/nats/nats.conf > /dev/null <<'EOF'
# NATS Server Configuration - Single Leaf Node
port: 4222
http_port: 8222

# Server identification
server_name: "cim-leaf-01"

# JetStream configuration
jetstream {
  store_dir: "/usr/local/var/nats/jetstream"

  # Memory limits (adjust based on your RAM)
  max_memory_store: 64G

  # Disk limits (adjust based on your storage)
  max_file_store: 1T
}

# Logging
logfile: "/var/log/nats-server.log"
debug: false
trace: false

# Monitoring
http: "0.0.0.0:8222"

# Security (will add PKI later)
# operator: "/usr/local/etc/nats/creds/operator.jwt"
# resolver: URL(nats://localhost:4222)

# Limits (adjust for your workload)
max_connections: 10000
max_payload: 1MB
max_pending: 256MB
EOF

# Create JetStream directory
sudo mkdir -p /usr/local/var/nats/jetstream

# Set permissions
sudo chown -R $(whoami) /usr/local/var/nats
sudo chown -R $(whoami) /usr/local/etc/nats
```

### 1.5 Start NATS

```bash
# Start NATS via launchd
sudo launchctl load -w /Library/LaunchDaemons/nats.plist

# Or start manually for testing
nats-server --config /usr/local/etc/nats/nats.conf

# Verify NATS is running
nats server info

# Check JetStream is enabled
nats stream list
```

### 1.6 Deploy PKI from cim-keys

```bash
# Copy PKI credentials from cim-keys repository
cd /path/to/cim-keys

# Copy operator JWT
sudo cp operators/thecowboyai/thecowboyai.jwt \
  /usr/local/etc/nats/creds/operator.jwt

# Copy account JWTs
sudo mkdir -p /usr/local/var/nats/jwt
for account in SYSTEM MORTGAGE_UNDERWRITING ORGANIZATION PEOPLE; do
  sudo cp accounts/$account/$account.jwt /usr/local/var/nats/jwt/
done

# Update NATS configuration to enable JWT auth
sudo tee -a /usr/local/etc/nats/nats.conf > /dev/null <<'EOF'

# JWT Authentication
operator: "/usr/local/etc/nats/creds/operator.jwt"

resolver: {
  type: full
  dir: "/usr/local/var/nats/jwt"
  allow_delete: false
  interval: "2m"
}
EOF

# Restart NATS
sudo launchctl unload /Library/LaunchDaemons/nats.plist
sudo launchctl load /Library/LaunchDaemons/nats.plist
```

### 1.7 Deploy Domain Services

**Domain services connect to local NATS:**

```rust
// Example: person-service
use async_nats;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Connect to leaf node NATS
    let client = async_nats::ConnectOptions::with_credentials_file(
        "/path/to/cim-keys/users/PEOPLE/person-service/person-service.creds"
    )?
    .connect("nats://localhost:4222")
    .await?;

    // Your domain logic here
    // ...

    Ok(())
}
```

**Deployment options:**

**Option A: Native macOS Services**
```bash
# Build your domain service
cargo build --release

# Create launchd plist
sudo tee /Library/LaunchDaemons/com.thecowboyai.person-service.plist > /dev/null <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.thecowboyai.person-service</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/person-service</string>
    </array>
    <key>KeepAlive</key>
    <true/>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/var/log/person-service.log</string>
    <key>StandardErrorPath</key>
    <string>/var/log/person-service.error.log</string>
</dict>
</plist>
EOF

# Start service
sudo launchctl load /Library/LaunchDaemons/com.thecowboyai.person-service.plist
```

**Option B: Docker Containers**
```bash
# Build Docker image
docker build -t person-service:latest .

# Run container
docker run -d \
  --name person-service \
  --restart unless-stopped \
  -v /path/to/cim-keys:/cim-keys:ro \
  -e NATS_URL=nats://host.docker.internal:4222 \
  -e NATS_CREDS=/cim-keys/users/PEOPLE/person-service/person-service.creds \
  person-service:latest
```

### 1.8 Verify Single Leaf Deployment

```bash
# Check NATS health
nats server info

# Check JetStream streams
nats stream list

# Test event publishing
nats pub test.deployment "Hello from Mac Studio leaf node"

# Monitor system resources
top
# Verify you have plenty of headroom in RAM and CPU

# Check service logs
tail -f /var/log/person-service.log
```

---

## Part 2: Scaling to NATS Cluster

When your single leaf node needs more capacity or high availability, scale to a cluster.

### 2.1 When to Scale to Cluster

**Scale when you experience:**
- High load approaching leaf node capacity
- Need for high availability (zero downtime)
- Geographic distribution requirements
- Compliance requiring redundancy

**Cluster benefits:**
- Automatic failover
- Load distribution
- Data replication (R3)
- Zero-downtime updates

### 2.2 Cluster Options

#### Option A: Self-Hosted Cluster (3 Mac Studios)

**Recommended Setup:**
- 3 Mac Studio M4 Ultra nodes (512GB RAM each)
- 10Gb network switch connecting nodes
- Same location (office, data center)

**Configuration:**
```nix
# Each node's NATS config
cluster {
  name: "thecowboyai"
  port: 6222

  routes: [
    nats://mac-studio-1.local:6222
    nats://mac-studio-2.local:6222
    nats://mac-studio-3.local:6222
  ]
}
```

**Cost:**
- Hardware: 3 × $8,000 = $24,000
- Network: ~$1,000 (10Gb switch)
- Total: ~$25,000 one-time

**Benefits:**
- Complete control
- No monthly costs
- High performance local network
- Data stays on-premises

#### Option B: Cloud-Hosted Cluster

**Recommended Platforms:**
- **AWS**: EC2 instances in VPC
- **GCP**: Compute Engine instances
- **Azure**: Virtual Machines

**Example: AWS Deployment**
```bash
# 3 EC2 instances
# Instance type: m7g.8xlarge (32 vCPU, 128GB RAM)
# Storage: 1TB gp3 EBS per instance
# Network: 10Gbps

# Cost estimate:
# 3 × $1.3088/hour = $3.93/hour
# Monthly: ~$2,830
# Annual: ~$34,400
```

**Configuration managed via Terraform:**
```hcl
# terraform/nats-cluster.tf
resource "aws_instance" "nats_node" {
  count         = 3
  ami           = "ami-xxxxx"  # NixOS AMI
  instance_type = "m7g.8xlarge"

  vpc_security_group_ids = [aws_security_group.nats.id]

  tags = {
    Name = "nats-node-${count.index + 1}"
    Role = "cim-cluster"
  }
}
```

**Benefits:**
- Scalable on demand
- Managed backups
- Geographic distribution
- Professional SLAs

**Drawbacks:**
- Ongoing monthly costs
- Data in cloud
- Network latency between client and cloud

### 2.3 Hybrid: Leaf Node + Cloud Cluster

**Best of both worlds:**
- Mac Studio leaf node in office (local, fast)
- Cloud cluster for redundancy and scale
- Leaf connects to cluster as backup

```nix
# Mac Studio leaf configuration
leafnodes {
  remotes = [
    {
      url: "nats://cluster-node-1.cloud:7422"
      credentials: "/usr/local/etc/nats/creds/leaf.creds"
    }
  ]
}
```

**Benefits:**
- Local performance for office operations
- Cloud redundancy for critical data
- Failover to cloud if office network fails
- Scale cluster independently

---

## Part 3: Production Deployment Checklist

### 3.1 Security Hardening

```bash
# ✅ TLS encryption enabled
# ✅ JWT authentication configured
# ✅ Subject-based permissions enforced
# ✅ Private keys secured in cim-keys repository
# ✅ Firewall rules configured
# ✅ Regular credential rotation scheduled

# Generate TLS certificates (if not done in Step 6b)
# See Step 6b Phase 4 for complete TLS setup
```

### 3.2 Monitoring Setup

**NATS Monitoring:**
```bash
# Enable NATS HTTP monitoring
# Already enabled in nats.conf: http_port: 8222

# Access monitoring endpoints
curl http://localhost:8222/varz      # Server info
curl http://localhost:8222/connz     # Connections
curl http://localhost:8222/routez    # Routes (cluster)
curl http://localhost:8222/jsz       # JetStream stats
```

**Prometheus + Grafana (Recommended):**
```yaml
# docker-compose.yml for monitoring stack
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    volumes:
      - grafana-data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=changeme

  nats-exporter:
    image: natsio/prometheus-nats-exporter:latest
    command: -varz http://host.docker.internal:8222

volumes:
  prometheus-data:
  grafana-data:
```

### 3.3 Backup Strategy

**JetStream Data Backup:**
```bash
#!/usr/bin/env bash
# backup-jetstream.sh

BACKUP_DIR="/backups/nats/$(date +%Y-%m-%d)"
JETSTREAM_DIR="/usr/local/var/nats/jetstream"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Stop NATS (optional for consistent backup)
# sudo launchctl unload /Library/LaunchDaemons/nats.plist

# Backup JetStream data
tar czf "$BACKUP_DIR/jetstream-$(date +%H-%M-%S).tar.gz" \
  -C "$(dirname $JETSTREAM_DIR)" \
  "$(basename $JETSTREAM_DIR)"

# Restart NATS (if stopped)
# sudo launchctl load /Library/LaunchDaemons/nats.plist

# Verify backup
ls -lh "$BACKUP_DIR"

# Optional: Upload to S3 or backup service
# aws s3 cp "$BACKUP_DIR" s3://my-backups/nats/ --recursive
```

**Schedule Backups:**
```bash
# Add to crontab
crontab -e

# Daily backup at 2 AM
0 2 * * * /usr/local/bin/backup-jetstream.sh

# Keep 30 days of backups
0 3 * * * find /backups/nats -type d -mtime +30 -exec rm -rf {} \;
```

**cim-keys Backup:**
```bash
# cim-keys is already in git, but create offline backup
cd /path/to/cim-keys

# Create encrypted backup
tar czf - . | gpg --encrypt --recipient ops@yourdomain.com \
  > /backups/cim-keys/cim-keys-$(date -I).tar.gz.gpg

# Store offline (USB drive, safe)
```

### 3.4 Disaster Recovery

**Recovery Procedure:**
```bash
# 1. Provision new Mac Studio (if hardware failure)

# 2. Install nix-darwin and NATS (follow 1.2-1.4)

# 3. Restore PKI from cim-keys
git clone private-repo:/cim-keys.git
# Deploy operator and account JWTs

# 4. Restore JetStream data from backup
cd /backups/nats/YYYY-MM-DD
tar xzf jetstream-HH-MM-SS.tar.gz -C /usr/local/var/nats/

# 5. Restart NATS
sudo launchctl load /Library/LaunchDaemons/nats.plist

# 6. Verify data integrity
nats stream list
nats stream info DOMAIN_MORTGAGE_UNDERWRITING_EVENTS

# 7. Redeploy domain services
# Follow 1.7 procedures

# 8. Verify production operation
# Run health checks
```

### 3.5 Performance Tuning

**Mac Studio Optimization:**
```bash
# Increase file descriptor limits (add to /etc/launchd.conf)
limit maxfiles 65536 200000

# Disable spotlight indexing on JetStream directory
sudo mdutil -i off /usr/local/var/nats

# Disable Time Machine for JetStream directory
tmutil addexclusion /usr/local/var/nats/jetstream

# Enable network performance mode
sudo nvram boot-args="serverperfmode=1"
```

**NATS Tuning:**
```conf
# Add to nats.conf

# Connection limits
max_connections: 10000
max_subscriptions: 0  # unlimited

# Payload limits
max_payload: 8MB

# Performance
write_deadline: "10s"
```

### 3.6 Documentation

**Maintain operational docs:**
```bash
# Create docs directory in your CIM repository
mkdir -p docs/operations

# Document your deployment
docs/operations/
├── deployment-topology.md      # Your specific setup
├── runbook.md                  # Common operations
├── troubleshooting.md          # Known issues and fixes
├── disaster-recovery.md        # DR procedures
└── contact-list.md             # On-call contacts
```

---

## Part 4: Post-Deployment Operations

### 4.1 Health Checks

**Daily Health Check Script:**
```bash
#!/usr/bin/env bash
# health-check.sh

echo "=== CIM Health Check: $(date) ==="

# NATS server health
echo "NATS Server:"
nats server ping || echo "❌ NATS not responding"

# JetStream health
echo "JetStream:"
nats stream list | grep -c "DOMAIN_" || echo "❌ No streams found"

# Service health (check each domain service)
echo "Domain Services:"
curl -s http://localhost:8080/health | jq '.status' || echo "❌ Service unhealthy"

# Resource usage
echo "Resources:"
echo "Memory: $(vm_stat | grep 'Pages active' | awk '{print $3}')"
echo "Disk: $(df -h /usr/local/var/nats | tail -1 | awk '{print $5}')"

# Event throughput (last hour)
echo "Event Throughput:"
nats stream info DOMAIN_MORTGAGE_UNDERWRITING_EVENTS | grep "Messages:"

echo "=== Health Check Complete ==="
```

### 4.2 Capacity Planning

**Monitor growth metrics:**
```bash
# Weekly capacity report
#!/usr/bin/env bash

REPORT_FILE="/var/log/capacity-report-$(date -I).txt"

{
  echo "=== Weekly Capacity Report ==="
  echo "Date: $(date)"

  # JetStream storage growth
  echo "JetStream Storage:"
  du -sh /usr/local/var/nats/jetstream

  # Event counts per stream
  echo "Event Counts:"
  for stream in $(nats stream list | grep DOMAIN_ | awk '{print $1}'); do
    COUNT=$(nats stream info $stream | grep "Messages:" | awk '{print $2}')
    echo "  $stream: $COUNT events"
  done

  # Connection count trend
  echo "Connections:"
  curl -s http://localhost:8222/connz | jq '.num_connections'

  # Recommendations
  echo "Recommendations:"
  DISK_USAGE=$(df /usr/local/var/nats | tail -1 | awk '{print $5}' | sed 's/%//')
  if [ $DISK_USAGE -gt 70 ]; then
    echo "  ⚠️  Disk usage above 70%, consider adding storage"
  fi

} > "$REPORT_FILE"

cat "$REPORT_FILE"
```

**When to scale:**
- Disk usage > 70%: Add storage or prune old streams
- Memory usage > 80%: Add RAM or scale to cluster
- CPU consistently > 60%: Scale to cluster for load distribution
- Event latency increasing: Scale to cluster

### 4.3 Upgrades and Maintenance

**NATS Upgrade Procedure:**
```bash
# 1. Backup current state
/usr/local/bin/backup-jetstream.sh

# 2. Update nix-darwin configuration
# Edit darwin-configuration.nix to specify new NATS version

# 3. Rebuild system
darwin-rebuild switch

# 4. Verify NATS version
nats-server --version

# 5. Test functionality
nats stream list
nats pub test.upgrade "Upgrade successful"

# 6. Monitor logs
tail -f /var/log/nats-server.log
```

**Domain Service Updates:**
```bash
# Zero-downtime deployment pattern
# 1. Deploy new version alongside old
# 2. Health check new version
# 3. Gradually shift traffic
# 4. Decommission old version

# Example with Docker
docker run -d --name person-service-v2 person-service:v2
# Verify health
curl http://localhost:8081/health
# Update load balancer or DNS
# Stop old version
docker stop person-service-v1
```

---

## Part 5: Common Deployment Patterns

### 5.1 Development → Staging → Production

**Environment Separation:**
```bash
# Use NATS accounts for environment isolation
development/    # DEVELOPMENT account
staging/        # STAGING account
production/     # PRODUCTION account

# Each environment has own streams
dev.domain.mortgage.application.created
staging.domain.mortgage.application.created
prod.domain.mortgage.application.created
```

### 5.2 Blue-Green Deployment

**Two identical production environments:**
```bash
# Blue environment (current production)
blue-leaf-node:4222

# Green environment (new version)
green-leaf-node:4222

# Traffic switch via DNS or load balancer
# nats.yourdomain.com -> blue (then -> green)
```

### 5.3 Canary Deployment

**Gradual rollout:**
```bash
# Route 5% traffic to new version
# Monitor for errors
# Gradually increase to 100%

# Using NATS subject-based routing
# 95% -> service-v1
# 5%  -> service-v2
```

---

## Success Criteria

By the end of Step 7, you should have:

✅ **Single Leaf Node** (Mac Studio or equivalent) deployed and operational
✅ **NATS JetStream** running with persistent storage
✅ **PKI and Security** configured from cim-keys
✅ **Domain Services** deployed and connected to NATS
✅ **Monitoring** setup (NATS metrics, optional Prometheus/Grafana)
✅ **Backups** automated and tested
✅ **Documentation** created for operations team
✅ **Health Checks** running daily
✅ **Disaster Recovery** plan documented and tested

**Optional (when ready to scale):**
✅ NATS Cluster deployed (self-hosted or cloud)
✅ High availability validated
✅ Load distribution working
✅ Failover tested

---

## SAGE Commands Summary

```bash
# Deployment Planning
@sage What hardware should I use for my CIM deployment?
@sage Should I start with a leaf node or cluster?
@sage Generate deployment topology for [requirements]

# Single Leaf Deployment
@sage Configure NATS on Mac Studio for [domain]
@sage Deploy domain services to leaf node
@sage Setup monitoring for single leaf deployment

# Cluster Deployment
@sage Should I self-host or use cloud for my cluster?
@sage Generate Terraform configuration for AWS NATS cluster
@sage Configure leaf node to connect to cluster

# Operations
@sage Create backup procedures for [deployment]
@sage Generate health check scripts
@sage Create disaster recovery plan
```

---

## Cost Comparison

### Single Leaf Node (Mac Studio)
- **Upfront**: $8,000 (Mac Studio M4 Ultra 512GB)
- **Monthly**: $0 (assuming existing network/power)
- **3-Year Total**: $8,000

### Self-Hosted Cluster (3 Mac Studios)
- **Upfront**: $24,000 (3 × Mac Studio) + $1,000 (networking)
- **Monthly**: ~$100 (power, network)
- **3-Year Total**: ~$28,600

### Cloud-Hosted Cluster (AWS)
- **Upfront**: $0
- **Monthly**: ~$2,830 (3 × m7g.8xlarge + storage + network)
- **3-Year Total**: ~$101,880

### Hybrid (Leaf + Cloud Cluster)
- **Upfront**: $8,000 (Mac Studio)
- **Monthly**: ~$2,830 (cloud cluster)
- **3-Year Total**: ~$109,880

**Recommendation**: Start with Mac Studio leaf node ($8,000), scale to self-hosted cluster when needed (~$25,000 total).

---

## Next Steps

🎉 **Congratulations! You've completed the Getting Started guides!**

You now have:
- ✅ Cloned and initialized cim-start (Step 1)
- ✅ Defined your CIM purpose (Step 2)
- ✅ Created organization domain (Step 3)
- ✅ Added people domain (Step 4)
- ✅ Chosen your development path (Step 5)
- ✅ Built domain or infrastructure (Step 6a/6b)
- ✅ Deployed to production (Step 7)

**Your CIM is now operational!**

### Continue Your Journey:

**For Domain Enhancement:**
- Explore [Domain Creation Guide](../domain-creation/) for advanced patterns
- Learn [Event Storming](../domain-creation/event-storming.md) for discovering new aggregates
- Study [DDD Patterns](../development/ddd-patterns.md) for complex domains

**For Infrastructure Optimization:**
- Review [NATS Best Practices](../infrastructure/nats-best-practices.md)
- Setup [Advanced Monitoring](../infrastructure/monitoring.md)
- Implement [Security Hardening](../infrastructure/security.md)

**For Team Collaboration:**
- Use [Agent System](../agent-system/) for coordinated development
- Leverage [SAGE](../agent-system/sage.md) for orchestration
- Explore [Specialized Agents](../agent-system/specialized-agents.md)

**For Research Integration:**
- Study [TRM Foundations](../research-integration/trm-foundations.md)
- Learn [Conceptual Spaces](../research-integration/conceptual-spaces.md)
- Understand [Mathematical Foundations](../research-integration/mathematical-foundations.md)

---

## Troubleshooting

### Mac Studio Specific Issues

**NATS Won't Start:**
```bash
# Check logs
tail -f /var/log/nats-server.log

# Verify configuration
nats-server --config /usr/local/etc/nats/nats.conf -t

# Check permissions
ls -la /usr/local/var/nats/jetstream
```

**Performance Issues:**
```bash
# Check system load
top

# Check disk I/O
iostat 1

# Check network
nettop

# Verify NATS metrics
curl http://localhost:8222/varz | jq
```

**Out of Memory:**
```bash
# Check JetStream memory usage
nats stream report

# Reduce max_memory_store in nats.conf
# Increase swap (not recommended for production)
# Upgrade to more RAM
```

### General Deployment Issues

**Services Can't Connect to NATS:**
```bash
# Verify NATS is listening
lsof -i :4222

# Test connectivity
nats pub test "hello"

# Check credentials
nats --creds /path/to/creds pub test "hello"

# Verify JWT is valid
nsc describe jwt -f /usr/local/etc/nats/creds/operator.jwt
```

**Events Not Persisting:**
```bash
# Check JetStream is enabled
nats stream list

# Verify stream configuration
nats stream info DOMAIN_YOUR_EVENTS

# Check disk space
df -h /usr/local/var/nats

# Review NATS logs
tail -f /var/log/nats-server.log | grep -i jetstream
```

---

**Remember**: Start simple with a single leaf node. Scale when you need it, not before. The Mac Studio M4 Ultra provides excellent performance for most CIM deployments.

---

**Deployment Complete! Your CIM is Live! 🚀**
