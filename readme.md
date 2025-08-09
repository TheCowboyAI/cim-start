# CIM-Start: Domain-Driven Development Starter Kit

Copyright 2025 - Cowboy AI, LLC

## 🚀 Purpose

CIM-Start is your starting point for building a new domain-specific Composable Information Machine (CIM). It provides:

- **Production-ready NATS JetStream environment** for domain event storage
- **Comprehensive subject algebra** for organizing events, commands, and projections  
- **Domain discovery templates and guides** for event storming and modeling
- **Complete monitoring stack** with Prometheus and Grafana dashboards
- **Event-driven architecture patterns** with stream management tools
- **Domain-specific agent framework** for intelligent automation

## 📁 Project Structure

```
cim-start/
├── .github/          # GitHub workflows and templates
├── agents/           # CIM agent configurations
│   ├── system/       # System agents (monitoring, ops)
│   ├── integration/  # Integration agents (APIs, sync)
│   ├── ai/          # AI agents (NLP, ML, decision making)  
│   ├── user/        # User agents (workflows, notifications)
│   ├── templates/   # Agent configuration templates
│   ├── examples/    # Complete agent integration examples
│   └── schemas/     # JSON schemas for agent validation
├── doc/             # Domain documentation and guides
│   ├── quick-start.md
│   ├── event-storming-guide.md
│   ├── nats-setup.md
│   └── agents-guide.md
├── domains/         # Your domain definitions
│   └── example-business/
└── docker-compose.yml  # NATS infrastructure
```

## 🎯 Quick Start

### 1. Deploy NATS JetStream Environment (2 minutes)

```bash
# Start the complete CIM NATS environment
make dev

# Or manually:
docker-compose up -d
./scripts/init-streams.sh
```

### 2. Test Domain Event Storage (1 minute)

```bash
# Test the event infrastructure
make test-events

# Watch events in real-time
make watch-events
```

### 3. Start Defining Your Domain (15 minutes)

```bash
# Create your domain definition
cp domains/example-business/domain-definition.yaml domains/my-domain/

# Use event storming guide
cat doc/event-storming-guide.md

# Or use the quick template
cat doc/quick-start.md
```

### 4. Monitor Your Environment

```bash
# Open monitoring dashboards
make monitor

# NATS Dashboard: http://localhost:8222
# Prometheus: http://localhost:9090  
# Grafana: http://localhost:3000 (admin/admin)
```

## 🏗️ Building Your Domain

### Step 1: Discovery
Start by identifying the key events in your business domain:
- What happens in your business?
- Who initiates these actions?
- What are the outcomes?

### Step 2: Model
Define your domain using the provided templates:
- Events (past-tense facts)
- Commands (user intentions)
- Aggregates (consistency boundaries)
- Policies (automated rules)

### Step 3: Assemble
Use existing CIM modules instead of building from scratch:
- `cim-events` - Event sourcing
- `cim-projections` - CQRS views
- `cim-domain-identity` - Authentication
- `cim-security` - Authorization
- `cim-workflow` - Business processes

### Step 4: Implement
Follow event-driven patterns:
```rust
// Commands trigger events
Command::CreateOrder { ... } 
  → OrderCreated { ... }
  → StockReserved { ... }
  → PaymentRequested { ... }
```

## 🐳 NATS JetStream Setup

### Docker Compose (Quickest)
```yaml
# docker-compose.yml provided
# Includes:
# - NATS server with JetStream
# - Monitoring dashboard
# - Persistent storage
```

### NixOS VM (Production-like)
```bash
# Build and run VM with NATS
nix build .#nats-vm
./result/bin/run-nats-vm
```

### Local Development
```bash
# Install NATS locally
nix develop
nats-server -js
```

## 📚 Documentation

- `/doc/quick-start.md` - 15-minute domain starter
- `/doc/event-storming-guide.md` - Collaborative discovery process
- `/doc/nats-setup.md` - NATS infrastructure guide
- `/doc/agents-guide.md` - Complete agent integration guide
- `/agents/README.md` - Agent architecture overview

## 🤖 CIM Agents

CIM-Start includes a complete agent framework with four agent types:

### System Agents
- Infrastructure monitoring and health checks
- Resource management and auto-scaling
- Operational automation

### Integration Agents  
- External API connections and data sync
- Protocol translation and service orchestration
- Third-party system integration

### AI Agents
- Natural language processing and conversation management
- Fraud detection and risk analysis
- Pattern recognition and decision making

### User Agents
- Workflow automation and task management
- Notification delivery and communication
- User interface automation

Agents integrate seamlessly with your domain events and participate in business workflows through NATS messaging.

## 🔧 Available Modules

CIM provides 38+ modules you can assemble:

### Core
- `cim-events` - Event store
- `cim-projections` - Read models
- `cim-graph` - Knowledge graphs

### Domain
- `cim-domain-identity` - Users & auth
- `cim-domain-workflow` - Business processes
- `cim-domain-policy` - Business rules

### Infrastructure  
- `cim-network` - Network topology
- `cim-flashstor` - Object storage
- `cim-security` - Authorization

## 🎓 Learning Path

1. **Start Simple**: One aggregate, 3-5 events
2. **Add Complexity**: Multiple aggregates, policies
3. **Cross-Domain**: Integration with other domains
4. **Production**: Clustering, monitoring, deployment

## 📖 Example Domain

See `/domains/example-business/` for a complete e-commerce domain with:
- Customer registration
- Product catalog
- Order management
- Inventory tracking
- Fulfillment workflow

## 🚦 Next Steps

1. Clone this repository
2. Define your first events
3. Start NATS JetStream
4. Implement your aggregates
5. Build projections
6. Test with real scenarios

## 📝 License

MIT

## 🤝 Contributing

Contributions welcome! Please read our contributing guidelines.

## 💬 Support

- GitHub Issues: [Report bugs or request features]
- Documentation: [Full CIM documentation]
- Community: [Join our Discord]