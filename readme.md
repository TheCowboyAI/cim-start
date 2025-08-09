# CIM-Start: Domain-Driven Development Starter Kit

## 🚀 Purpose

CIM-Start is your starting point for building a new domain-specific Composable Information Machine (CIM). It provides:

- Domain discovery templates and guides
- NATS JetStream infrastructure setup
- Claude AI integration for guided development
- Event-driven architecture patterns
- Assembly-first module composition

## 📁 Project Structure

```
cim-start/
├── .claude/           # Claude AI instructions and agents
├── doc/              # Domain documentation and guides
│   ├── quick-start.md
│   ├── event-storming-guide.md
│   └── domain-templates/
├── domains/          # Your domain definitions
│   └── example-business/
├── nix/              # NixOS configurations
│   ├── containers/   # Docker/Podman containers
│   └── vms/         # Virtual machine configs
└── scripts/         # Automation scripts
```

## 🎯 Quick Start

### 1. Define Your Domain (15 minutes)

```bash
# Start with the quick template
cat doc/quick-start.md

# Or use event storming for discovery
cat doc/event-storming-guide.md
```

### 2. Start NATS JetStream

```bash
# Using Docker
docker-compose up -d

# Using Nix
nix run .#nats-server

# Using VM
nix run .#nats-vm
```

### 3. Generate Your Domain

```bash
# Use Claude to help build your domain
# Claude will guide you through:
# - Event definition
# - Aggregate modeling  
# - Command handlers
# - Projection design
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
- `/doc/domain-templates/` - YAML/JSON templates
- `/doc/nats-setup.md` - NATS infrastructure guide
- `/.claude/README.md` - AI assistance instructions

## 🤖 Claude Integration

This project includes Claude AI instructions to help you:
- Design your domain model
- Generate event definitions
- Create aggregate implementations
- Build projections
- Set up infrastructure

Just ask Claude to help with any aspect of your domain development!

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