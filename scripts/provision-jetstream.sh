#!/bin/bash
# 
# JetStream Infrastructure Provisioning Script
# Provisions JetStream container or VM for CIM Domain
#
# Usage: ./scripts/provision-jetstream.sh --domain <domain-name> --org <organization> --admin <admin-email> --type <container|vm>

set -euo pipefail

# Default values
INFRASTRUCTURE_TYPE="container"
DOMAIN_NAME=""
ORGANIZATION=""
ADMINISTRATOR=""
PURPOSE=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --domain)
      DOMAIN_NAME="$2"
      shift 2
      ;;
    --org)
      ORGANIZATION="$2"
      shift 2
      ;;
    --admin)
      ADMINISTRATOR="$2"
      shift 2
      ;;
    --purpose)
      PURPOSE="$2"
      shift 2
      ;;
    --type)
      INFRASTRUCTURE_TYPE="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 --domain <name> --org <org> --admin <admin> --type <container|vm>"
      echo ""
      echo "Provisions JetStream infrastructure for a CIM domain"
      echo ""
      echo "Options:"
      echo "  --domain    Domain name (kebab-case)"
      echo "  --org       Organization name"
      echo "  --admin     Administrator email"
      echo "  --purpose   Domain purpose description"
      echo "  --type      Infrastructure type: container (default) or vm"
      echo "  -h, --help  Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

# Validate required parameters
if [[ -z "$DOMAIN_NAME" || -z "$ORGANIZATION" || -z "$ADMINISTRATOR" ]]; then
  echo "Error: --domain, --org, and --admin are required"
  exit 1
fi

# Validate domain name format (kebab-case)
if ! [[ "$DOMAIN_NAME" =~ ^[a-z0-9-]{3,50}$ ]]; then
  echo "Error: Domain name must be 3-50 characters, lowercase, numbers, and hyphens only"
  exit 1
fi

echo "🚀 Provisioning DEV Channel JetStream container for CIM Domain"
echo "   Domain: $DOMAIN_NAME"
echo "   Organization: $ORGANIZATION" 
echo "   Administrator: $ADMINISTRATOR"
echo "   Type: $INFRASTRUCTURE_TYPE"

# Create domain directory structure
DOMAIN_DIR="domains/${DOMAIN_NAME}"
mkdir -p "$DOMAIN_DIR"/{config,logs,data}

# Generate JetStream configuration
generate_jetstream_config() {
  cat > "$DOMAIN_DIR/config/nats.conf" << EOF
# DEV Channel JetStream Configuration for Domain: $DOMAIN_NAME
# Organization: $ORGANIZATION
# Administrator: $ADMINISTRATOR

server_name: "${DOMAIN_NAME}-nats"
listen: 0.0.0.0:4222
monitor_port: 8222

# JetStream Configuration
jetstream: {
  store_dir: "/data/jetstream"
  domain: "${DOMAIN_NAME}"
  
  # Storage limits based on domain requirements
  max_memory_store: 1GB
  max_file_store: 10GB
  
  # Domain-specific limits
  max_streams: 100
  max_consumers: 1000
}

# Clustering (if needed for HA)
cluster: {
  name: "${DOMAIN_NAME}-cluster"
  listen: 0.0.0.0:6222
}

# Security and Access Control
accounts: {
  ${ORGANIZATION}: {
    users: [
      {
        user: "admin"
        password: "\$2a\$11\$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)"
      }
    ]
  }
}

# Logging
log_file: "/logs/nats.log"
logtime: true
debug: false
trace: false
EOF
}

# Generate Docker Compose for container deployment
generate_docker_compose() {
  cat > "$DOMAIN_DIR/docker-compose.yml" << EOF
version: '3.8'

services:
  ${DOMAIN_NAME}-nats:
    image: nats:2.10-alpine
    container_name: ${DOMAIN_NAME}-nats
    ports:
      - "4222:4222"  # Client connections
      - "8222:8222"  # Monitoring
      - "6222:6222"  # Clustering
    volumes:
      - ./config/nats.conf:/etc/nats/nats.conf:ro
      - ./data:/data
      - ./logs:/logs
    command: ["-c", "/etc/nats/nats.conf"]
    restart: unless-stopped
    environment:
      - NATS_DOMAIN=${DOMAIN_NAME}
      - NATS_ORG=${ORGANIZATION}
    labels:
      - "cim.domain=${DOMAIN_NAME}"
      - "cim.organization=${ORGANIZATION}"
      - "cim.administrator=${ADMINISTRATOR}"
      - "cim.type=jetstream"

  ${DOMAIN_NAME}-monitoring:
    image: prom/prometheus:latest
    container_name: ${DOMAIN_NAME}-prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./config/prometheus.yml:/etc/prometheus/prometheus.yml:ro
    depends_on:
      - ${DOMAIN_NAME}-nats
    restart: unless-stopped

volumes:
  ${DOMAIN_NAME}-data:
    driver: local
  ${DOMAIN_NAME}-logs:
    driver: local
EOF
}

# Generate Prometheus monitoring config
generate_prometheus_config() {
  cat > "$DOMAIN_DIR/config/prometheus.yml" << EOF
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: '${DOMAIN_NAME}-nats'
    static_configs:
      - targets: ['${DOMAIN_NAME}-nats:8222']
    metrics_path: '/varz'
    
  - job_name: '${DOMAIN_NAME}-jetstream'
    static_configs:
      - targets: ['${DOMAIN_NAME}-nats:8222']
    metrics_path: '/jsz'
EOF
}

# Generate VM configuration using cloud-init
generate_vm_config() {
  cat > "$DOMAIN_DIR/config/cloud-init.yml" << EOF
#cloud-config
# VM Configuration for CIM Domain: $DOMAIN_NAME

hostname: ${DOMAIN_NAME}-jetstream
users:
  - name: cimadmin
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - # ADD SSH PUBLIC KEY HERE

packages:
  - docker.io
  - docker-compose
  - curl
  - jq

runcmd:
  - systemctl enable docker
  - systemctl start docker
  - usermod -aG docker cimadmin
  
  # Install NATS CLI
  - curl -sf https://binaries.nats.dev/nats-io/nats/v2@latest | sh
  - mv nats /usr/local/bin/
  
  # Create CIM domain structure
  - mkdir -p /opt/cim/${DOMAIN_NAME}
  - chown -R cimadmin:cimadmin /opt/cim
  
  # Setup domain-specific services
  - cd /opt/cim/${DOMAIN_NAME}
  - # Copy configuration files here
  
write_files:
  - path: /opt/cim/${DOMAIN_NAME}/README.md
    content: |
      # CIM Domain: ${DOMAIN_NAME}
      
      Organization: ${ORGANIZATION}
      Administrator: ${ADMINISTRATOR}
      
      ## Management Commands
      
      Start services:
      \`\`\`bash
      cd /opt/cim/${DOMAIN_NAME}
      docker-compose up -d
      \`\`\`
      
      Monitor status:
      \`\`\`bash
      docker-compose ps
      curl http://localhost:8222/varz
      \`\`\`
      
      Access logs:
      \`\`\`bash
      docker-compose logs -f
      \`\`\`
EOF
}

# Main provisioning logic
echo "📝 Generating configuration files..."

generate_jetstream_config
generate_prometheus_config

if [[ "$INFRASTRUCTURE_TYPE" == "container" ]]; then
  echo "🐳 Generating Docker Compose configuration..."
  generate_docker_compose
  
  echo "🚀 Starting JetStream container..."
  cd "$DOMAIN_DIR"
  docker-compose up -d
  
  # Wait for NATS to start
  echo "⏳ Waiting for NATS to be ready..."
  sleep 5
  
  # Verify connectivity
  if curl -s http://localhost:8222/varz > /dev/null; then
    echo "✅ JetStream container is running and accessible"
  else
    echo "❌ Failed to verify JetStream connectivity"
    exit 1
  fi
  
elif [[ "$INFRASTRUCTURE_TYPE" == "vm" ]]; then
  echo "🖥️  Generating VM cloud-init configuration..."
  generate_vm_config
  
  echo "📋 VM configuration generated at: $DOMAIN_DIR/config/cloud-init.yml"
  echo "📝 To deploy VM, use your cloud provider with the generated cloud-init.yml"
  echo ""
  echo "Example commands for different providers:"
  echo "  AWS:    aws ec2 run-instances --user-data file://$DOMAIN_DIR/config/cloud-init.yml ..."
  echo "  GCP:    gcloud compute instances create ... --metadata-from-file user-data=$DOMAIN_DIR/config/cloud-init.yml"
  echo "  Azure:  az vm create ... --custom-data $DOMAIN_DIR/config/cloud-init.yml"
  
fi

# Create domain management scripts
cat > "$DOMAIN_DIR/manage-domain.sh" << EOF
#!/bin/bash
# Domain management script for $DOMAIN_NAME

case "\$1" in
  start)
    docker-compose up -d
    ;;
  stop)
    docker-compose down
    ;;
  status)
    docker-compose ps
    curl -s http://localhost:8222/varz | jq .
    ;;
  logs)
    docker-compose logs -f
    ;;
  *)
    echo "Usage: \$0 {start|stop|status|logs}"
    exit 1
    ;;
esac
EOF
chmod +x "$DOMAIN_DIR/manage-domain.sh"

# Generate domain metadata
cat > "$DOMAIN_DIR/domain-metadata.json" << EOF
{
  "domain_name": "$DOMAIN_NAME",
  "organization": "$ORGANIZATION", 
  "administrator": "$ADMINISTRATOR",
  "purpose": "$PURPOSE",
  "infrastructure_type": "$INFRASTRUCTURE_TYPE",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "jetstream_config": {
    "client_url": "nats://localhost:4222",
    "monitoring_url": "http://localhost:8222",
    "cluster_port": 6222
  },
  "management": {
    "start_command": "./manage-domain.sh start",
    "stop_command": "./manage-domain.sh stop",
    "status_command": "./manage-domain.sh status"
  }
}
EOF

echo ""
echo "✅ CIM Domain infrastructure provisioned successfully!"
echo ""
echo "📁 Domain directory: $DOMAIN_DIR"
echo "🔧 Management script: $DOMAIN_DIR/manage-domain.sh"
echo "📊 Monitoring: http://localhost:8222"
echo "📝 Metadata: $DOMAIN_DIR/domain-metadata.json"
echo ""
echo "Next steps:"
echo "1. Initialize NATS streams: ./scripts/init-streams.sh $DOMAIN_NAME"
echo "2. Test connectivity: ./scripts/test-domain-events.sh $DOMAIN_NAME"
echo "3. Create domain definition: domains/$DOMAIN_NAME/domain.cim-graph.yaml"
echo ""
echo "🎯 Your CIM Domain '$DOMAIN_NAME' is ready for event-driven development!"