# NATS JetStream Setup Guide for Domain Events

Copyright 2025 - Cowboy AI, LLC

## Overview

CIM-Start provides a production-ready NATS JetStream environment specifically configured for domain event storage with a comprehensive subject algebra. This setup enables event sourcing, CQRS patterns, and domain-driven architecture.

## Subject Algebra

CIM uses a hierarchical subject structure to organize domain events:

```
{environment}.{category}.{domain}.{aggregate}.{event_type}.{event_id}
```

**Examples:**
```
dev.domain.sales.order.created.550e8400-e29b-41d4-a716-446655440000
prod.command.inventory.product.update
prod.projection.order-summary.update
```

See `/nats-config/subject-algebra.md` for complete documentation.

## 🚀 Quick Start

### 1. Start NATS Environment

```bash
# Start the complete CIM NATS stack
docker-compose up -d

# Check that all services are running
docker-compose ps
```

### 2. Initialize Domain Streams

```bash
# Initialize streams for your domains
./scripts/init-streams.sh

# Or initialize specific domains
./scripts/init-streams.sh sales inventory customer
```

### 3. Test Domain Events

```bash
# Run comprehensive event tests
./scripts/test-domain-events.sh

# Monitor events in real-time
nats sub "dev.domain.>"
```

## 🏗️ Architecture

### Streams Created

1. **Domain Event Streams** - One per domain
   - `DOMAIN_SALES_EVENTS` → `*.domain.sales.>`
   - `DOMAIN_INVENTORY_EVENTS` → `*.domain.inventory.>`
   - `DOMAIN_CUSTOMER_EVENTS` → `*.domain.customer.>`

2. **Command Streams** - One per domain
   - `DOMAIN_SALES_COMMANDS` → `*.command.sales.>`
   - `DOMAIN_INVENTORY_COMMANDS` → `*.command.inventory.>`

3. **Global Streams**
   - `PROJECTIONS` → `*.projection.>`
   - `SAGAS` → `*.saga.>`

### Subject Patterns

```bash
# Domain Events (persistent, file storage)
{env}.domain.{domain}.{aggregate}.{event}.{id}

# Commands (ephemeral, memory storage) 
{env}.command.{domain}.{aggregate}.{action}

# Projections (read models)
{env}.projection.{view}.{operation}

# Sagas/Workflows
{env}.saga.{process}.{event}

# Snapshots
{env}.snapshot.{domain}.{aggregate}.{id}
```

## 🛠️ Configuration

### Environment Variables

```bash
# Set your environment
export CIM_ENVIRONMENT=dev  # dev, staging, prod

# Set NATS connection
export NATS_URL=nats://localhost:4222
```

### Account Security

The configuration includes three accounts:

1. **DOMAIN** - For domain operations
   - User: `domain_user` / Pass: `domain_pass`
   - Can publish/subscribe to all domain subjects

2. **QUERY** - For read-only access
   - User: `query_user` / Pass: `query_pass`
   - Read-only access to events and projections

3. **SYS** - For system operations
   - User: `system` / Pass: `system_pass`
   - Administrative access

## 📊 Monitoring

### NATS Dashboard
Access the monitoring dashboard: http://localhost:8222

Key endpoints:
- `/healthz` - Health check
- `/jsz` - JetStream information
- `/varz` - Server variables
- `/connz` - Connection details

### Prometheus Metrics
Access Prometheus: http://localhost:9090
- NATS metrics collected via nats-surveyor
- Custom dashboards available in Grafana

### Grafana Dashboards  
Access Grafana: http://localhost:3000 (admin/admin)
- Pre-configured NATS dashboards
- Domain event visualization
- Stream health monitoring

## 🧪 Testing Your Setup

### Manual Testing

```bash
# Test basic connectivity
nats --server=nats://localhost:4222 server ping

# Publish a domain event
nats pub "dev.domain.sales.order.created.$(uuidgen)" '{
  "event_id": "'$(uuidgen)'",
  "aggregate_id": "'$(uuidgen)'", 
  "event_type": "OrderCreated",
  "timestamp": "'$(date -Iseconds)'",
  "data": {"customer_id": "123", "total": 99.99}
}'

# Subscribe to domain events
nats sub "dev.domain.sales.>"

# View stream contents
nats stream view DOMAIN_SALES_EVENTS
```

### Automated Testing

```bash
# Run the complete test suite
./scripts/test-domain-events.sh

# Test specific environment
CIM_ENVIRONMENT=staging ./scripts/test-domain-events.sh
```

## 🔧 Stream Management

### List All Streams
```bash
nats stream list
```

### Stream Information
```bash
nats stream info DOMAIN_SALES_EVENTS
```

### Create Consumer
```bash
nats consumer add DOMAIN_SALES_EVENTS ORDER_PROCESSOR \
  --filter "*.domain.sales.order.>" \
  --ack explicit \
  --deliver all
```

### Backup/Restore
```bash
# Backup stream
nats stream backup DOMAIN_SALES_EVENTS /backup/sales-events.tar.gz

# Restore stream
nats stream restore /backup/sales-events.tar.gz
```

## 🌍 Environment-Specific Configuration

### Development
- **Prefix**: `dev.`
- **Retention**: 1 day
- **Replication**: 1
- **Storage**: Mixed (events=file, commands=memory)

### Staging
- **Prefix**: `staging.`
- **Retention**: 7 days  
- **Replication**: 1
- **Storage**: File-based
- **Monitoring**: Full observability stack

### Production
- **Prefix**: `prod.`
- **Retention**: 30+ days
- **Replication**: 3 (cluster mode)
- **Storage**: File-based with backups
- **Security**: TLS, authentication, authorization
- **Monitoring**: Full observability + alerting

## 🔐 Security Best Practices

### Development
```bash
# Use provided accounts for development
NATS_USER=domain_user NATS_PASS=domain_pass
```

### Production
```bash
# Use strong passwords and TLS
# Update nats.conf with production credentials
# Enable TLS encryption
# Set up proper firewall rules
```

## 🚨 Troubleshooting

### Common Issues

**Stream not found**
```bash
# Reinitialize streams
./scripts/init-streams.sh

# Check stream status
nats stream list
```

**Permission denied**
```bash
# Verify account permissions
nats server report accounts

# Use correct credentials
nats --user=domain_user --password=domain_pass pub test.subject "test"
```

**High memory usage**
```bash
# Check JetStream usage
nats server report jetstream

# Purge old messages
nats stream purge DOMAIN_SALES_EVENTS --keep 1000
```

## 📈 Scaling Considerations

### Single Node (Development)
- Use provided docker-compose.yml
- File storage for persistence
- Memory storage for commands

### Cluster (Production)  
- 3+ node NATS cluster
- Replicated streams (R=3)
- Load balancer for client connections
- Separate monitoring infrastructure

### Partitioning
- Separate domains into different streams
- Use aggregate ID for message ordering
- Consider subject-based sharding for high volume

## 🎯 Next Steps

1. ✅ Start NATS environment: `docker-compose up -d`
2. ✅ Initialize streams: `./scripts/init-streams.sh`
3. ✅ Test setup: `./scripts/test-domain-events.sh`
4. → Define your domain events in `/domains/your-domain/`
5. → Start publishing events to your streams
6. → Build projections and read models
7. → Set up monitoring and alerting

## 📚 Additional Resources

- [Subject Algebra Documentation](../nats-config/subject-algebra.md)
- [Domain Definition Guide](../domains/example-business/README.md)
- [NATS JetStream Documentation](https://docs.nats.io/jetstream)
- [CIM Architecture Guide](https://github.com/thecowboyai/cim)