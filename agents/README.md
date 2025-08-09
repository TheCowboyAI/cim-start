# CIM Agents

Copyright 2025 - Cowboy AI, LLC

## Overview

CIM agents are composable, event-driven modules that participate in domain workflows. Unlike traditional subagent hierarchies, CIM agents are domain-specific modules that communicate through NATS events and integrate seamlessly with business processes.

## Agent Types

### System Agents
- Infrastructure monitoring
- Resource management  
- Health checks
- Automated operations

### Integration Agents
- External API connections
- Data synchronization
- Protocol translation
- Service orchestration

### AI Agents
- Natural language processing
- Decision making
- Pattern recognition
- Conversational interfaces

### User Agents
- Interface automation
- Workflow execution
- Task management
- Notification handling

## Directory Structure

```
agents/
├── system/          # System agents
├── integration/     # Integration agents  
├── ai/             # AI agents
├── user/           # User agents
└── templates/      # Agent templates
```

## Agent Architecture

### Core Components

- **AgentMarker**: ECS component for agent identification
- **AgentMetadata**: Core agent information and capabilities
- **CapabilitiesComponent**: Skills and abilities
- **PermissionsComponent**: Access control and security
- **ConfigurationComponent**: Runtime settings

### Communication Patterns

Agents communicate through NATS subjects:

```
agent.commands.*     # Agent command messages
agent.events.*       # Agent event notifications
agent.status.*       # Agent health and status
```

### Key Commands

- `DeployAgent`: Deploy new agent instance
- `ActivateAgent`: Activate dormant agent
- `ConfigureAgent`: Update agent configuration
- `TerminateAgent`: Gracefully stop agent

## Integration with Domains

Agents integrate with domain events and commands:

```yaml
# Domain definition with agent integration
domain:
  name: example-business
  agents:
    - name: order-processor
      type: system
      triggers:
        - event: OrderCreated
          command: ProcessOrder
    - name: payment-gateway
      type: integration
      triggers:
        - event: PaymentRequested
          command: ProcessPayment
```

## Getting Started

1. Choose an agent type from the templates
2. Configure agent metadata and capabilities
3. Define event triggers and command handlers
4. Deploy to your domain
5. Monitor through NATS streams

## Examples

See the `examples/` directory for complete agent implementations and integration patterns.