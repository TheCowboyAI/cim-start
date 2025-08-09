# User Agents

Copyright 2025 - Cowboy AI, LLC

User agents automate user-facing tasks and interface interactions.

## Available User Agents

### 🌟 Interactive Domain Collection Agent

**Purpose**: Guides users through Domain creation and assignment in CIM-Start systems.

**Location**: `agents/user/domain-collection-agent.sh`

**Type**: Interactive CLI Agent

**Key Features**:
- Interactive step-by-step domain collection
- Real-time validation of domain components
- CIM graph generation
- NATS JetStream integration
- Comprehensive error handling and user guidance

**Usage**:
```bash
# Run the interactive domain collection agent
./agents/user/domain-collection-agent.sh

# Or use the configuration directly
# (Implementation depends on your agent runtime)
```

**Required Components Collected**:
- Domain Name (required) - Unique identifier following CIM naming conventions
- Domain Purpose (required) - Clear description of the domain's scope and responsibilities

**Outputs**:
- CIM graph file (`domains/{domain-name}/domain.cim-graph.yaml`)
- Domain definition file (`domains/{domain-name}/domain-definition.yaml`)
- NATS JetStream streams initialization
- Domain creation events published to NATS

---

## Other Agent Types

### Interface Automator
- **Purpose**: Automate UI interactions and workflows
- **Triggers**: User requests, scheduled tasks
- **Capabilities**: Form filling, button clicking, navigation

### Workflow Executor
- **Purpose**: Execute complex user workflows
- **Triggers**: Workflow start events
- **Capabilities**: Multi-step processes, error handling

### Task Manager
- **Purpose**: Manage user tasks and assignments
- **Triggers**: Task creation, deadlines
- **Capabilities**: Scheduling, reminders, delegation

### Notification Handler
- **Purpose**: Manage user notifications and alerts
- **Triggers**: Important events, status changes
- **Capabilities**: Multi-channel delivery, preferences

## Configuration Examples

See `templates/` directory for complete configuration examples.