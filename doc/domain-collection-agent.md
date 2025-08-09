# Interactive Domain Collection Agent

Copyright 2025 - Cowboy AI, LLC

## Overview

The Interactive Domain Collection Agent is a foundational component of the CIM-Start system that guides users through the critical process of Domain creation and assignment. A Domain establishes a "Domain of Reasoning" - a contextual boundary that serves as the foundation for all CIM system development.

## Purpose

This agent provides:
- **Interactive guidance** for collecting Domain information
- **Real-time validation** against CIM invariants
- **CIM graph generation** from collected data
- **NATS JetStream integration** for event-driven architecture
- **Comprehensive error handling** and user support

## Domain Fundamentals

### What is a Domain?

In CIM systems, a Domain is the foundational entity that establishes contextual boundaries. Domains invariantly have two required components:

1. **Domain Name** - A unique identifier for the domain
2. **Domain Purpose** - A clear description of what the domain represents

### Why Domains Matter

Domains typically represent:
- A business or organization
- A specific business capability
- An individual's domain of expertise
- A bounded context within a larger system

## Architecture

### Agent Components

```yaml
Agent Type: User Agent
Agent ID: user-domain-collection-001
Version: 1.0.0
Runtime: Bash script with YAML configuration
```

### Key Features

- **Interactive CLI Interface**: Step-by-step guided collection
- **Real-time Validation**: Immediate feedback on input validity
- **CIM Graph Generation**: Structured output following CIM patterns
- **NATS Integration**: Event publishing to JetStream
- **Error Recovery**: Comprehensive error handling and retry logic

## Usage

### Prerequisites

1. **CIM-Start Environment**: Ensure your CIM-Start system is set up
2. **NATS JetStream**: Running NATS server (optional for offline use)
3. **Bash Shell**: Unix-like environment with bash
4. **Permissions**: Write access to the `domains/` directory

### Running the Agent

```bash
# Navigate to the CIM-Start root directory
cd /path/to/cim-start

# Run the interactive domain collection agent
./agents/user/domain-collection-agent.sh

# Alternative: Run from the agents/user directory
cd agents/user
./domain-collection-agent.sh
```

### Environment Configuration

The agent respects the following environment variables:

```bash
# NATS server URL (default: nats://localhost:4222)
export NATS_URL="nats://your-nats-server:4222"

# CIM environment (default: dev)
export CIM_ENVIRONMENT="dev"  # or "staging", "prod"
```

## Interactive Workflow

### 1. Welcome and Introduction

The agent begins with a welcome banner and explanation of the domain collection process:

```
 ░▒▓██████▓▒░░▒▓█▓▒░▒▓██████████████▓▒░
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░
 ... CIM Domain Collection Agent ...

Welcome to the CIM Domain Collection Agent!
This agent will guide you through creating a new Domain...
```

### 2. Domain Name Collection

**Prompt**: "What is the name of your domain?"

**Validation Rules**:
- 3-50 characters in length
- Lowercase letters, numbers, and hyphens only
- No consecutive hyphens
- No leading or trailing hyphens
- Must be unique within the CIM system

**Examples**:
- ✅ `e-commerce`
- ✅ `customer-service`
- ✅ `inventory-mgmt`
- ❌ `E-Commerce` (uppercase)
- ❌ `--invalid--` (consecutive hyphens)
- ❌ `ab` (too short)

### 3. Domain Purpose Collection

**Prompt**: "What is the purpose of this domain?"

**Validation Rules**:
- 10-500 characters in length
- Meaningful descriptive content
- Clear explanation of domain scope

**Example**:
```
Manages customer orders, inventory allocation, and fulfillment 
processes for our e-commerce platform. Handles order lifecycle 
from creation through delivery and provides integration points 
for payment processing and shipping services.
```

### 4. Validation and Confirmation

The agent displays collected information and asks for confirmation:

```
Domain Information Collected:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Name: e-commerce
Purpose: Manages customer orders, inventory allocation, and fulfillment...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Does this information look correct? (y/n):
```

### 5. Domain Creation and CIM Graph Generation

Upon confirmation, the agent:
1. Creates the domain directory structure
2. Generates a CIM graph
3. Creates a basic domain definition file
4. Initializes NATS streams
5. Publishes domain creation events

## Output Structure

### Directory Structure

```
domains/
└── {domain-name}/
    ├── domain.cim-graph.yaml      # Generated CIM graph
    └── domain-definition.yaml     # Basic domain definition
```

### CIM Graph Format

The generated CIM graph follows this structure:

```yaml
cim_graph:
  format_version: "1.0.0"
  graph_id: "unique-graph-id"
  generated_at: "2025-01-XX-XX-XX"
  generated_by: "user-domain-collection-001"
  
  domain:
    entity_type: "Domain"
    entity_id: "domain-name"
    
    components:
      name:
        component_type: "DomainName"
        value: "domain-name"
        required: true
        validated_at: "2025-XX-XX"
      
      purpose:
        component_type: "DomainPurpose"
        value: "Domain purpose description..."
        required: true
        validated_at: "2025-XX-XX"
    
    relationships:
      - relationship_type: "establishes"
        target_entity: "DomainOfReasoning"
        cardinality: "one-to-one"
      
      - relationship_type: "manages"
        target_entity: "EventStream" 
        target_id: "DOMAIN_{NAME}_EVENTS"
        cardinality: "one-to-many"
```

### Domain Definition Template

```yaml
domain:
  name: domain-name
  description: Domain purpose description...
  created_at: "2025-XX-XX"
  created_by: "domain-collection-agent"
  
  # Placeholder sections for future development
  events: []
  commands: []
  aggregates: []
  policies: []
  external_systems: []
  agents: []
  workflows: {}
```

## NATS Integration

### Event Publishing

The agent publishes the following events to NATS JetStream:

1. **Domain Collection Started**
   - Subject: `{env}.agent.domain-collection.session.started.{session-id}`
   - Schema: `agents/schemas/domain-collection-started.json`

2. **Domain Created**
   - Subject: `{env}.domain.{domain-name}.domain.created.{event-id}`
   - Schema: `agents/schemas/domain-created.json`

### Stream Initialization

Upon successful domain creation, the agent initializes the following NATS streams:

- **Events Stream**: `DOMAIN_{DOMAIN_NAME}_EVENTS`
- **Commands Stream**: `DOMAIN_{DOMAIN_NAME}_COMMANDS`
- **Snapshots Stream**: `DOMAIN_{DOMAIN_NAME}_SNAPSHOTS`

## Error Handling

### Input Validation Errors

The agent provides clear, actionable error messages:

```bash
✗ Domain name must use lowercase letters and hyphens only.
✗ Domain name must be 3-50 characters long.
✗ This domain name already exists. Please choose another.
```

### System Errors

- **NATS Connectivity**: Graceful degradation when NATS is unavailable
- **File System**: Clear messages for permission or disk space issues
- **Stream Initialization**: Continues with warnings if stream creation fails

### Recovery Options

- Users can restart the collection process at any time
- Invalid input prompts for correction without losing progress
- Partial failures provide clear next steps

## Integration with CIM-Start

### Makefile Integration

Add to your CIM-Start Makefile:

```makefile
create-domain: ## Create a new domain interactively
	@./agents/user/domain-collection-agent.sh

init-domain-streams: ## Initialize streams for existing domains
	@make init-streams
```

### Development Workflow

1. **Domain Creation**: Use this agent as the entry point
2. **Domain Modeling**: Extend the generated domain definition
3. **Event Storming**: Use `doc/event-storming-guide.md`
4. **Implementation**: Follow CIM patterns and use CIM modules

## Best Practices

### Domain Naming

- Use descriptive but concise names
- Follow kebab-case convention
- Avoid overly generic names like "data" or "system"
- Consider the domain's primary responsibility

### Domain Purpose

- Clearly state the domain's primary responsibility
- Include boundaries and scope
- Mention key stakeholders or users
- Avoid implementation details

### After Domain Creation

1. Review and customize the generated domain definition
2. Use event storming to discover domain events
3. Define aggregates and bounded contexts
4. Implement using appropriate CIM modules

## Troubleshooting

### Common Issues

**Agent won't start**:
```bash
# Check script permissions
chmod +x ./agents/user/domain-collection-agent.sh

# Check bash availability
which bash
```

**NATS connection errors**:
```bash
# Check NATS server status
make status

# Start NATS if not running
make start
```

**Domain already exists**:
- Choose a different domain name
- Or remove the existing domain directory if appropriate

**Permission errors**:
```bash
# Check write permissions
ls -la domains/

# Fix permissions if needed
chmod 755 domains/
```

### Debug Mode

For additional debug information:

```bash
# Enable bash debug mode
bash -x ./agents/user/domain-collection-agent.sh
```

## Extensions and Customization

### Custom Validation

Modify the validation functions in the script:

```bash
validate_domain_name() {
    local name="$1"
    # Add custom validation logic
}

validate_domain_purpose() {
    local purpose="$1" 
    # Add custom validation logic
}
```

### Custom CIM Graph Templates

Modify the `generate_cim_graph` function to customize the generated graph structure.

### Additional Components

Extend the agent to collect additional domain components beyond name and purpose.

## Support

For issues, questions, or contributions:

- **Documentation**: `doc/` directory
- **Examples**: `domains/example-business/`
- **Configuration**: `agents/user/domain-collection-agent.yaml`
- **Implementation**: `agents/user/domain-collection-agent.sh`

## Next Steps

After creating a domain:

1. **Explore the Example**: Review `domains/example-business/`
2. **Event Storming**: Use `doc/event-storming-guide.md`
3. **Quick Start**: Follow `doc/quick-start.md`
4. **Agent Integration**: See `doc/agents-guide.md`

The Interactive Domain Collection Agent provides the foundation for your CIM system development journey. Use it as the starting point for establishing clear domain boundaries and building robust, event-driven applications.