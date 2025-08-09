# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CIM-Start is a domain-driven development starter kit for building Composable Information Machines (CIM). It provides a production-ready NATS JetStream environment with comprehensive tooling for event-driven architecture, domain modeling, and intelligent agent integration.

**Key Technologies:**
- NATS JetStream for event streaming and persistence
- Docker Compose for infrastructure orchestration
- Nix flake for reproducible development environment
- Domain-driven design patterns and event sourcing
- Agent-based automation framework

## Common Commands

### Development Environment
```bash
# Start complete development environment (recommended)
make dev

# Alternative Docker commands
docker-compose up -d              # Start NATS stack
./scripts/init-streams.sh         # Initialize event streams
```

### Testing and Validation
```bash
# Test domain event system
make test-events                  # Test event publishing/consuming
./scripts/test-domain-events.sh   # Run domain event tests

# Monitor real-time events
make watch-events                 # Watch all domain events
make watch-commands              # Watch all commands
```

### NATS Management
```bash
# Stream operations
make list-streams                            # List all NATS streams
make stream-info STREAM=DOMAIN_SALES_EVENTS  # Show stream details
make purge-stream STREAM=DOMAIN_SALES_EVENTS # Purge stream data

# Access NATS CLI
make shell                       # Get shell in nats-box container
```

### Monitoring and Debugging
```bash
# Open monitoring dashboards
make monitor                     # Opens NATS, Prometheus, Grafana dashboards

# Debug information
make debug                       # Show comprehensive system status
make status                      # Show service health
```

### Environment Management
```bash
# Different environments
make dev                         # Development (default)
make staging                     # Staging environment  
make prod                        # Production (use with caution)

# Cleanup
make clean                       # Remove containers and volumes
make stop                        # Stop services
make restart                     # Restart all services
```

### Nix Commands (if using nix)
```bash
nix develop                      # Enter development shell
nix run .#nats                   # Run NATS server directly
nix run .#stack                  # Start Docker stack
nix run .#generate example       # Generate new domain template
```

## Architecture Overview

### Domain Structure
The project follows Domain-Driven Design principles with:

- **domains/**: Domain definitions (YAML-based domain models)
- **agents/**: Four types of intelligent agents (system, integration, AI, user)
- **scripts/**: Infrastructure automation and testing scripts
- **doc/**: Comprehensive guides for domain modeling and event storming

### Event-Driven Architecture
Events follow a hierarchical subject structure in NATS:

**Core Pattern**: `{environment}.{category}.{domain}.{aggregate}.{event}.{id}`

**Categories**:
- `domain` - Domain events (persistent, file storage)
- `command` - Commands (transient, memory storage)
- `projection` - Read model updates (persistent, compacted)
- `saga` - Process manager events (persistent, short retention)
- `snapshot` - Aggregate snapshots (persistent, long retention)

**Examples**:
```
dev.domain.sales.order.created.550e8400-e29b-41d4-a716-446655440000
dev.command.sales.order.create
dev.projection.order-summary.update
```

### Agent Integration Framework
Four agent types integrate with domain events:

1. **System Agents** (`agents/system/`) - Infrastructure monitoring, health checks
2. **Integration Agents** (`agents/integration/`) - External API connections, data sync  
3. **AI Agents** (`agents/ai/`) - NLP, fraud detection, decision making
4. **User Agents** (`agents/user/`) - Workflow automation, notifications

Agents are configured in YAML and trigger on domain events automatically.

### Streams Configuration
Each domain gets dedicated streams:
- **Events**: `DOMAIN_{DOMAIN}_EVENTS` (file storage, 30d retention)
- **Commands**: `DOMAIN_{DOMAIN}_COMMANDS` (memory storage, 1h retention)  
- **Snapshots**: `DOMAIN_{DOMAIN}_SNAPSHOTS` (file storage, 90d retention)

Global streams:
- **Projections**: Read model updates (7d retention)
- **Sagas**: Process workflows (7d retention)

## Domain Boundary Creation Workflow

### 1. Establish Domain Boundary (Primary Entry Point)
Use the Domain Boundary Agent to establish your Domain of Reasoning with communication capability:

```bash
# Invoke the Domain Boundary Agent via Claude Code sub-agent
# This follows a systematic 3-phase approach:
# Phase 1: Establish boundary (Domain Name + Purpose)  
# Phase 2: Invoke NATS with subject algebra
# Phase 3: Set up Claude communication hooks
```

**Boundary-First Architecture:**
1. **Create Boundary** → Define Domain with Name + Purpose (invariant components)
2. **Enable Communication** → Invoke NATS JetStream with Domain-specific subject algebra
3. **Connect Claude** → Set up Claude-NATS communication hooks within the boundary

**Domain Category Requirements:**
A Domain is a Category in Category Theory terms, containing Objects and Arrows:
- **Name** (required): Unique identifier for the Domain Category
- **Purpose** (required): Clear description of the Category's scope and reasoning context  
- Both components are invariant and must be provided for any valid Domain Category

**Mathematical Structure:**
- **DATA STRUCTURE**: Graph Theory / Network Theory is the foundational data structure
- **CATEGORY THEORY MAPPING**:
  - **Domain = Category**: The Domain represents a mathematical Category
  - **Objects = Entities = Nodes**: Objects within the Category are Entities, equivalent to Nodes in Graph Theory
  - **Arrows = Systems = Edges**: Arrows between Objects are Systems (morphisms), equivalent to Edges in Graph Theory
  - **Entities = Collections of Value Objects**: Each Entity/Node is composed of Value Objects (equivalent to Components in ECS)
  - **Value Objects = Components**: Atomic data components that compose Entities/Nodes
- **EVENT STORE ARCHITECTURE**:
  - **Sequential Events**: Event Store holds sequential list of Events with CID references to Object Store payloads
  - **Sequential Systems**: Event Store holds sequential list of Arrows/Systems with CID references to Object Store payloads
  - **Graph-based Storage**: All relationships stored using Graph Theory data structures
- **OBJECT STORE ARCHITECTURE (Smart File System)**:
  - **Content-Based Addressing**: Files stored like a smart network drive where identical files share the same location
  - **File Addresses**: Each file gets a unique "web address" based on what's inside it (like URLs but for file content)
  - **File Types**: Large files (Photos, Databases) and small files (data, documents, code) all handled efficiently
  - **Network Access**: Retrieve any file from anywhere by asking for its address
  - **Space Efficiency**: Event Store keeps file addresses instead of copying large files everywhere
- **CQRS ARCHITECTURE FOCUS**:
  - **WRITE Model Implementation**: Currently building the command and event handling (how data gets created and changed)
  - **READ Models Planned**: Query and reporting features will come later as Projections from the Event Store
  - **Separation Benefits**: Optimized for fast, consistent writes now; optimized reads added when needed

The boundary agent will:
- Guide you through collecting the required Domain Category components
- Validate that both Name and Purpose properly define the Category boundary
- Generate a cim-graph structure representing the Domain Category with Objects and Arrows
- Invoke NATS JetStream within the Domain Category scope
- Establish subject algebra for communication within the Category boundary
- Set up Claude communication hooks for the Category
- Create all necessary domain files and configurations following Category Theory principles

### 2. Domain Model Extension  
After Domain creation, extend the domain model in `domains/{domain-name}/domain-definition.yaml`:
- Events (past-tense facts)
- Commands (user intentions) 
- Aggregates (consistency boundaries)
- Policies (automated rules)
- External systems integration
- Agent workflows

### 3. Stream Initialization
```bash
# Initialize streams for new domain (usually done automatically by Domain Collection sub-agent)
./scripts/init-streams.sh my-domain

# Or reinitialize all discovered domains
make init-streams
```

### 4. Implementation
Follow the domain-driven patterns:
- Implement aggregates as consistency boundaries
- Commands produce domain events
- Use event sourcing for state reconstruction
- Apply CQRS for read/write separation

### 5. Testing
```bash
# Test event flows
make test-events

# Validate domain model
./scripts/test-domain-events.sh my-domain
```

## Domain Collection Claude Sub-Agent

**IMPORTANT**: When a user asks about creating a Domain, mentions needing to set up a Domain, or asks how to get started with CIM-Start, Claude Code should IMMEDIATELY invoke the Domain Collection sub-agent. This is the required entry point for establishing any CIM system.

### Auto-Invocation Triggers
Claude Code should automatically invoke the Domain Collection sub-agent when users:
- Ask "How do I create a Domain?"
- Say "I want to set up a new Domain"  
- Ask "How do I get started with CIM-Start?"
- Mention needing to establish a "Domain of Reasoning"
- Ask about Domain creation or assignment
- Request help with setting up their CIM system

When any of these triggers occur, Claude Code should use the Domain Collection sub-agent to guide them through the process. This ensures proper CIM compliance and graph structure.

### Sub-Agent Invocation Pattern
```
Task tool with subagent_type: "general-purpose"
Description: "Establish Domain Category and communication" 
Prompt: "You are the CIM Domain Category Agent. Your role is to establish a Domain as a Category (in Category Theory terms) and set up communication within that Category.

MATHEMATICAL FOUNDATIONS:
- DATA STRUCTURE: Graph Theory / Network Theory
- CATEGORY THEORY MAPPING:
  - Domain = Category (mathematical category containing Objects and Arrows)
  - Objects = Entities (composed of Value Objects/Components) = Nodes in Graph Theory
  - Arrows = Systems (morphisms between Entities) = Edges in Graph Theory
  - Value Objects = Components (atomic data components, equivalent to ECS Components)
- EVENT STORE ARCHITECTURE:
  - Sequential list of Events (Structured Values) with CID references to Object Store
  - Sequential list of Arrows (Systems) with CID references to Object Store
  - Graph Theory as underlying data structure for all relationships
- OBJECT STORE ARCHITECTURE (Smart File System on NATS):
  - Works like a network file system where files are automatically organized and shared
  - Each file gets a unique "address" (like a URL) based on its content
  - Files with identical content automatically share the same address (no duplicates)
  - Large files (Photos, Databases) and small files (data, documents) all stored efficiently
  - Files are organized like folders within folders, where combining files creates new folder addresses
  - Event Store holds file addresses instead of copying large files everywhere
- CQRS FOCUS: Currently implementing the WRITE Model (Commands and Events)
  - READ Models will be added later as Projections from the Event Store
  - This separation allows optimized writing now, optimized reading later

PHASE 1 - ESTABLISH CATEGORY:
1. A Domain Category MUST have exactly two invariant components:
   - Name (required): Unique identifier for the Domain Category
   - Purpose (required): Clear description of the Category's scope and reasoning context

2. Interactively collect these components from the user
3. Validate both are provided and meaningful for Category definition
4. Generate a cim-graph structure representing the Domain as a Category with provisions for Objects and Arrows

PHASE 2 - CREATE COMMUNICATION MECHANISM:
5. Invoke NATS JetStream for the Domain Category
6. Establish subject algebra for communication within the Category
7. Initialize Category-specific streams using the subject patterns:
   - {domain}.nodes.{entity}.{event}.{id} (Node/Entity/Object events - CID references stored in Event Store)
   - {domain}.edges.{system}.{action} (Edge/System/Arrow commands - CID references stored in Event Store)  
   - {domain}.objects.{cid}.{operation} (IPLD Object Store operations - content-addressed storage)
   - {domain}.graph.{network}.{operation} (Graph Theory operations)
   - {domain}.functors.{mapping}.{event} (Category functors)

PHASE 3 - SETUP CLAUDE-NATS HOOKS:
8. Create communication hooks for Claude to interact over NATS as functors
9. Set up event publishing/consuming patterns for Category operations
10. Configure Claude to communicate within the Domain Category boundary

Your output should include:
- Complete cim-graph YAML representing Domain as Category with Objects/Nodes, Arrows/Edges, and morphisms
- NATS subject algebra configuration for the Category with Graph Theory patterns and IPLD Object Store
- Stream initialization commands for Category communication, Event Store, and Object Store
- Claude-NATS communication hook setup as functors with CID-based object access
- Directory structure for Entities/Nodes (Objects), Systems/Edges (Arrows), and Value Objects (Components)
- Event Store configuration for sequential Events and Systems with CID references
- IPLD Object Store configuration for content-addressed storage on NATS JetStream
- CID-based retrieval and deduplication system setup
- Confirmation of Domain Category establishment with Graph Theory data structure, Event Store, Object Store, and communication ready

Be systematic following Category Theory: establish Category FIRST, then communication mechanism, then functors. This creates a proper Domain of Reasoning as a mathematical Category with internal communication capability."
```

### Sub-Agent Responsibilities
1. **Boundary Establishment**: Guide user through Domain Name and Purpose collection to create reasoning boundary
2. **Validation**: Ensure both invariant components are provided and valid for boundary definition
3. **CIM Graph Generation**: Structure Domain boundary as proper cim-graph with entities, components, and relationships  
4. **NATS Invocation**: Start NATS JetStream within the Domain boundary
5. **Subject Algebra Setup**: Establish communication patterns using Domain-specific subject algebra
6. **Stream Initialization**: Set up Domain-scoped NATS streams for internal communication
7. **Claude Hooks Configuration**: Create communication hooks for Claude to interact over NATS within the Domain
8. **Event Publishing**: Publish Domain boundary creation events to CIM event streams

### Domain Category Structure (cim-graph)
```yaml
# Category Theory representation with Graph Theory data structure
category:
  id: "domain-{domain-name}"
  type: "Category" 
  data_structure: "Graph Theory / Network Theory"
  components:
    - component_type: "Name"
      value: "{domain-name}"
      invariant: true
    - component_type: "Purpose"  
      value: "{domain-purpose}"
      invariant: true

# Objects/Nodes within the Category (Entities)
nodes:  # Objects in Category Theory = Nodes in Graph Theory
  - id: "entity-{entity-name}"
    type: "Entity"
    category: "domain-{domain-name}"
    graph_type: "Node"
    value_objects:  # Components in ECS terms
      - component_type: "Identifier"
        value: "{entity-id}"
      - component_type: "State"
        value: "{entity-state}"
      - component_type: "Properties"
        value: "{entity-properties}"

# Arrows/Edges within the Category (Systems/morphisms)
edges:  # Arrows in Category Theory = Edges in Graph Theory
  - id: "system-{system-name}"
    type: "System"
    category: "domain-{domain-name}"
    graph_type: "Edge"
    source_node: "entity-{source}"  # source Object/Node
    target_node: "entity-{target}"  # target Object/Node
    morphism: "{transformation-function}"

# Event Store structure with IPLD Object Store integration
event_store:
  events:  # Sequential list of Events with CID references
    - id: "{event-id}"
      type: "StructuredValue"
      node_id: "entity-{entity-name}"
      timestamp: "{timestamp}"
      payload_cid: "{ipld-cid-reference}"  # CID reference to Object Store
      payload_size: "{size-bytes}"
      payload_type: "small|large"
  
  systems:  # Sequential list of Arrows/Systems with CID references
    - id: "{system-id}"
      type: "SystemExecution"
      edge_id: "system-{system-name}"
      timestamp: "{timestamp}"
      transformation_cid: "{ipld-cid-reference}"  # CID reference to Object Store
      payload_size: "{size-bytes}"
      payload_type: "small|large"

# Object Store structure (Smart File System on NATS)
object_store:
  storage_type: "Smart File System"
  transport: "NATS JetStream"
  
  files:  # Content-addressed files
    - address: "{file-web-address}"  # Like a URL but for file content
      type: "Photo|Database|Document|Data|Code"
      size: "{size-bytes}"
      content_fingerprint: "{unique-content-id}"
      referenced_by: ["{event-id}", "{system-id}"]  # What uses this file
      created: "{timestamp}"
      
  folder_structure:  # Files organized like folders within folders
    - parent_address: "{folder-address}"
      child_addresses: ["{file1-address}", "{file2-address}", "{subfolder-address}"]
      # Combining files creates new folder addresses automatically
      
  automatic_features:
    duplicate_prevention: true  # Identical files share same address
    smart_sharing: true        # Files accessible from anywhere
    content_verification: true # Files always contain what their address promises
    
  access:
    retrieval_method: "Ask NATS for file by address"
    availability: "anywhere on network"
    reliability: "files never change once created"

# Communication mechanism for the Category with Graph Theory
communication:
  - id: "nats-{domain-name}"
    type: "CommunicationMechanism"
    data_structure: "Graph Theory / Network Theory"
    components:
      - component_type: "SubjectAlgebra"
        value: "{domain-name}.{nodes|edges}.{entity|system}.{action}.{id}"
        invariant: true
      - component_type: "StreamPattern"
        value: "DOMAIN_{DOMAIN_NAME}_{NODES|EDGES}"
        invariant: true
      - component_type: "EventStoreStreams"
        value: "DOMAIN_{DOMAIN_NAME}_EVENTS, DOMAIN_{DOMAIN_NAME}_SYSTEMS"
        invariant: true
      - component_type: "ObjectStoreStream"
        value: "DOMAIN_{DOMAIN_NAME}_OBJECTS"
        invariant: true
      - component_type: "FileRetrieval"
        value: "NATS request-response pattern for file-address-based retrieval"
        invariant: true
      - component_type: "FolderStructure"
        value: "Files organized like folders within folders, combining creates new addresses"
        invariant: true

# Graph Theory relationships and Category Theory morphisms
graph_relationships:
  - type: "node_connection"
    from_node: "entity-{source}"
    to_node: "entity-{target}"
    via_edge: "system-{system-name}"
    
morphisms:  # Category Theory morphisms
  - from: "domain-{domain-name}"
    to: "cim-system" 
    type: "category_inclusion"
  - from: "nats-{domain-name}"
    to: "domain-{domain-name}"
    type: "enables_communication_within_category"
  - from: "claude-hooks"
    to: "nats-{domain-name}"
    type: "functor_communication"
  - from: "event-store"
    to: "graph-structure"
    type: "sequential_to_graph_mapping"
  - from: "object-store"
    to: "event-store"
    type: "content_addressed_payload_storage"
  - from: "file-addresses"
    to: "object-store"
    type: "content_based_file_reference"
  - from: "folder-combination"
    to: "new-folder-address"
    type: "automatic_address_creation"
```

### Expected Outputs
- `domains/{domain-name}/domain.cim-graph.yaml` - CIM graph representing Domain as Category with Graph Theory data structure (Nodes/Edges)
- `domains/{domain-name}/domain-definition.yaml` - Domain Category model definition with Graph Theory foundation
- `domains/{domain-name}/nats-config.yaml` - Subject algebra and stream configuration for Category with Graph Theory patterns
- `domains/{domain-name}/claude-hooks.yaml` - Claude-NATS communication hooks as functors
- `domains/{domain-name}/nodes/` - Directory containing Entity definitions (Objects/Nodes in the Category/Graph)
- `domains/{domain-name}/edges/` - Directory containing System definitions (Arrows/Edges in the Category/Graph)
- `domains/{domain-name}/value-objects/` - Directory containing Value Object definitions (Components)
- `domains/{domain-name}/event-store.yaml` - Event Store configuration for sequential Events and Systems with CID references
- `domains/{domain-name}/object-store.yaml` - IPLD Object Store configuration for content-addressed storage
- NATS JetStream running with Category-specific streams for Graph Theory operations and IPLD Object Store
- Event Store streams: `DOMAIN_{DOMAIN_NAME}_EVENTS` (Events with CID references) and `DOMAIN_{DOMAIN_NAME}_SYSTEMS` (Systems with CID references)
- Object Store stream: `DOMAIN_{DOMAIN_NAME}_OBJECTS` (Smart file system with content-addressed files)
- File-address-based retrieval system over NATS for distributed file access
- Automatic deduplication and caching via content-based addressing (identical files share addresses)
- File organization like folders within folders, combining files creates new folder addresses automatically
- Claude communication hooks active within Domain Category boundary using Graph Theory data structures and Smart File System
- CQRS WRITE Model focus: Optimized for commands and events; READ Models (Projections) will be added later

## Claude-NATS Communication Hooks

Once the Domain boundary is established and NATS is invoked with subject algebra, Claude can communicate within the Domain using hooks.

### Hook Configuration Pattern
```yaml
# domains/{domain-name}/claude-hooks.yaml
hooks:
  domain_communication:
    type: "nats-publisher"
    subjects:
      - "{domain-name}.claude.interaction.started"
      - "{domain-name}.claude.interaction.completed" 
      - "{domain-name}.claude.task.created"
      - "{domain-name}.claude.task.updated"
    connection:
      url: "nats://localhost:4222"
      stream: "DOMAIN_{DOMAIN_NAME}_EVENTS"
      
  domain_listening:
    type: "nats-consumer"
    subjects:
      - "{domain-name}.domain.>"  # All domain events
      - "{domain-name}.command.>" # All commands
    connection:
      url: "nats://localhost:4222"
      consumer_group: "claude-{domain-name}"
```

### Hook Integration Commands
```bash
# Enable Claude-NATS hooks for a domain
./scripts/enable-claude-hooks.sh {domain-name}

# Test Claude communication within domain
./scripts/test-claude-nats.sh {domain-name}

# Monitor Claude activity within domain  
make watch-events | grep "claude"
```

### Communication Flow
1. **Domain Boundary Established** → Domain Name + Purpose defined
2. **NATS Invoked** → Subject algebra created for Domain
3. **Streams Initialized** → Domain-specific communication channels ready
4. **Claude Hooks Active** → Claude can publish/consume within Domain boundary
5. **Communication Enabled** → Claude operates within Domain of Reasoning

### Hook Event Examples
```bash
# Claude starting work within Domain
{domain-name}.claude.interaction.started.{session-id}

# Claude completing Domain task  
{domain-name}.claude.interaction.completed.{session-id}

# Claude creating Domain artifacts
{domain-name}.claude.task.created.{task-id}
```

This enables Claude to work entirely within the established Domain boundary using NATS as the communication mechanism.

## Key Files and Directories

### Configuration
- `docker-compose.yml` - Complete NATS infrastructure stack
- `nats.conf` - NATS server configuration
- `flake.nix` - Nix development environment
- `Makefile` - Development workflow automation

### Documentation  
- `doc/quick-start.md` - 15-minute domain template
- `doc/event-storming-guide.md` - Collaborative domain discovery
- `doc/nats-setup.md` - NATS infrastructure guide
- `doc/agents-guide.md` - Agent integration guide
- `doc/domain-creation-mathematics.md` - Mathematical foundations of domain creation
- `doc/structure-preserving-propagation.md` - How mathematical structures maintain properties across distributed systems
- `doc/object-store-user-guide.md` - Object Store explained as a smart network file system
- `nats-config/subject-algebra.md` - Subject naming patterns

### Examples
- `domains/example-business/` - Complete e-commerce domain example
- `agents/examples/` - Agent configuration examples

### Monitoring
- **NATS Dashboard**: http://localhost:8222
- **Prometheus**: http://localhost:9090  
- **Grafana**: http://localhost:3000 (admin/admin)

## Development Best Practices

### Event Design
- Use past-tense naming for events (`OrderCreated`, not `CreateOrder`)
- Include sufficient data for event consumers
- Events should be immutable and append-only
- Follow the subject algebra consistently

### Domain Modeling
- Start with event storming sessions to discover domain events
- Define aggregate boundaries around consistency needs
- Use policies for automated business rules
- Model external system integration explicitly

### Agent Integration
- Agents should be stateless and event-driven
- Use appropriate agent types for different automation needs
- Configure agents declaratively in YAML
- Test agent workflows with domain events

### Stream Management
- Use appropriate storage and retention policies per stream type
- Monitor stream sizes and consumer lag
- Implement proper error handling and retries
- Use subject-based permissions for security

## Troubleshooting

### NATS Connection Issues
```bash
# Check NATS health
make status

# View NATS logs
make logs-nats

# Test connectivity
docker-compose exec nats-box nats server ping
```

### Stream Issues
```bash
# List all streams and their status
make list-streams

# Check specific stream info
make stream-info STREAM=DOMAIN_SALES_EVENTS

# Debug stream configuration
make debug
```

### Event Flow Issues
```bash
# Watch events in real-time
make watch-events

# Test event publishing
make quick-test

# Check consumer lag
docker-compose exec nats-box nats consumer report
```

This starter kit provides everything needed to begin building event-driven domain applications with NATS JetStream and intelligent agents.