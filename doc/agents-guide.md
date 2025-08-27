# CIM Agents Integration Guide

Copyright 2025 - Cowboy AI, LLC

## 🎭 SAGE Orchestration System

**NEW: CIM-Start now includes SAGE - a master orchestrator coordinating 25 specialized expert agents!**

SAGE (Strategic Agent Guidance Engine) provides intelligent orchestration of all CIM development activities through a unified interface. Instead of manually coordinating agents, SAGE analyzes your requirements and automatically engages the right experts in the optimal sequence.

### The 26 Expert Agents

SAGE coordinates these specialized experts:

**Domain & Architecture (6)**: cim-expert, cim-domain-expert, ddd-expert, event-storming-expert, domain-expert, domain-ontologist-researcher
**Development & Testing (3)**: bdd-expert, tdd-expert, qa-expert
**Infrastructure (5)**: nats-expert, network-expert, nix-expert, git-expert, subject-expert
**UI/UX (4)**: iced-ui-expert, elm-architecture-expert, cim-tea-ecs-expert, ricing-expert
**Knowledge & Semantics (3)**: conceptual-spaces-expert, graph-expert, language-expert
**Organization & Context (4)**: people-expert, org-expert, location-expert, resource-expert
**Orchestration (1)**: sage (master coordinator)

## Overview

CIM agents are composable, event-driven modules that enhance domain workflows with intelligent automation. With SAGE orchestration, these agents work together seamlessly as a unified system rather than isolated components.

## Agent Architecture

### Core Principles

1. **SAGE-Orchestrated**: All agents coordinate through SAGE for optimal workflows
2. **Event-Driven**: Agents respond to domain events through NATS messaging
3. **Composable**: Mix and match agents based on domain needs
4. **Autonomous**: Each agent operates independently within defined boundaries
5. **Domain-Aware**: Agents understand and participate in business workflows
6. **Expert-Specialized**: Each of the 25 agents brings deep expertise in their domain

### Agent Types

#### System Agents
Handle infrastructure and operational concerns:
- Performance monitoring
- Resource management
- Health checks
- Automated operations

#### Integration Agents  
Connect domains with external systems:
- API connectors
- Data synchronization
- Protocol translation
- Service orchestration

#### AI Agents
Provide intelligent decision-making:
- Natural language processing
- Pattern recognition
- Fraud detection
- Conversational interfaces

#### User Agents
Automate user-facing processes:
- Workflow execution
- Task management
- Notification delivery
- Interface automation

## Getting Started with SAGE

### The SAGE-First Approach (Recommended)

```bash
# Simply ask SAGE to handle everything
@sage Create a complete agent system for my [domain]
@sage Set up monitoring agents for production
@sage Design an AI-powered customer service workflow
```

SAGE will:
1. Analyze your requirements
2. Engage relevant experts from the 25-agent team
3. Coordinate multi-agent workflows
4. Generate all necessary configurations
5. Validate the complete system

### Manual Agent Configuration (Advanced)

#### 1. Choose Agent Templates

Start with pre-built templates from `/agents/templates/`:

```bash
# Copy a template
cp agents/templates/system-agent.yaml agents/my-monitor.yaml

# Customize for your domain
vim agents/my-monitor.yaml
```

### 2. Configure Agent Triggers

Agents respond to domain events defined in your domain definition:

```yaml
triggers:
  - name: "order-placed"
    type: "event"
    event_pattern: "event.order.placed"
    command: "ProcessOrder"
```

### 3. Define Capabilities

Specify what your agent can do and what permissions it needs:

```yaml
capabilities:
  - name: "order-processing"
    description: "Process customer orders"
    permissions:
      - "read:order-data"
      - "write:order-events"
```

### 4. Set Up NATS Subjects

Configure how your agent communicates through NATS:

```yaml
configuration:
  nats:
    subjects:
      commands: "agent.order.commands"
      events: "agent.order.events"
      status: "agent.order.status"
```

## Integration with Domains

### Domain Event Integration

Agents integrate directly with domain events:

```yaml
# In domain-definition.yaml
agents:
  - id: "fraud-detector"
    type: "ai"
    triggers:
      - event: E004  # OrderPlaced
        command: "AnalyzeFraud"
```

### Agent Workflows

Define multi-agent workflows for complex processes:

```yaml
agent_workflows:
  order_processing:
    trigger: E004  # OrderPlaced
    agent_flow:
      - step: 1
        agent: "ai-fraud-detector"
        condition: "order.placed"
      - step: 2
        agent: "payment-gateway"
        condition: "fraud.approved"
```

## Configuration Management

### Environment Variables

Use environment variables for sensitive configuration:

```yaml
configuration:
  external_api:
    base_url: "${EXTERNAL_API_URL}"
    api_key: "${API_KEY}"
```

### Runtime Settings

Configure resource limits and restart policies:

```yaml
configuration:
  runtime:
    memory_limit: "512MB"
    cpu_limit: "0.5"
    restart_policy: "always"
```

## Deployment Options

### Local Development

Run agents locally for development:

```bash
# Start NATS
docker-compose up -d

# Deploy agent
nix run .#deploy-agent -- agents/my-agent.yaml
```

### Production Deployment

Deploy to production infrastructure:

```bash
# Deploy to Kubernetes
kubectl apply -f agents/production/

# Deploy to NixOS
nixos-rebuild switch --flake .#production
```

## Monitoring and Observability

### Agent Status

Monitor agent health through NATS subjects:

```bash
# Subscribe to agent status
nats sub "agent.*.status"

# Check specific agent
nats req "agent.my-agent.ping" ""
```

### Metrics Collection

Agents can expose metrics for monitoring:

```yaml
configuration:
  monitoring:
    metrics_endpoint: ":9090"
    health_check_endpoint: ":8080/health"
```

## Security Considerations

### Permissions Model

Agents operate with least-privilege permissions:

```yaml
capabilities:
  - name: "read-only-access"
    permissions:
      - "read:customer-data"
      # No write permissions
```

### Authentication

Agents authenticate using JWT tokens or API keys:

```yaml
configuration:
  authentication:
    type: "jwt"
    token: "${AGENT_JWT_TOKEN}"
```

## Examples

### Order Processing Pipeline

See `agents/examples/order-processing-agents.yaml` for a complete order processing pipeline using multiple agent types.

### Customer Service Workflow

See `agents/examples/customer-service-agents.yaml` for an AI-powered customer service implementation.

## Best Practices

### 1. Single Responsibility
Each agent should have a clear, focused purpose.

### 2. Event-First Design
Design agents to respond to events rather than polling for state.

### 3. Graceful Degradation
Ensure domain workflows continue even if agents are unavailable.

### 4. Configuration Management
Use environment variables and external configuration for deployment-specific settings.

### 5. Error Handling
Implement proper error handling and retry logic.

### 6. Monitoring
Include health checks and metrics in all production agents.

## Troubleshooting

### Common Issues

1. **Agent Not Starting**: Check NATS connectivity and configuration
2. **Events Not Triggering**: Verify event patterns match domain events
3. **Permission Errors**: Review capability permissions
4. **Resource Issues**: Check memory and CPU limits

### Debug Commands

```bash
# Check agent logs
nats req "agent.my-agent.logs" ""

# Test agent connectivity
nats req "agent.my-agent.ping" ""

# View agent configuration
nats req "agent.my-agent.config" ""
```

## Next Steps

### With SAGE Orchestration (Recommended)

1. **Ask SAGE for complete solutions**: `@sage Build a complete monitoring system`
2. **Let SAGE coordinate experts**: `@sage Integrate with external payment systems`
3. **Request complex workflows**: `@sage Create an AI-powered decision system`
4. **Get architectural guidance**: `@sage Review and optimize my agent architecture`

### Manual Approach (Advanced)

1. Start with system agents for monitoring
2. Add integration agents for external systems
3. Implement AI agents for intelligent decision making
4. Create user agents for workflow automation
5. Compose agents into complex workflows

## The 26 Expert Agents in Detail

Each expert agent brings specialized knowledge:

- **conceptual-spaces-expert**: Implements Gärdenfors' geometric theory of meaning
- **domain-ontologist-researcher**: Creates formal ontologies and knowledge structures
- **graph-expert**: Applies graph theory to domain modeling
- **language-expert**: Natural language processing and semantic analysis
- **location-expert**: Spatial and geographic modeling
- **org-expert**: Organizational structures and business processes
- **people-expert**: User modeling and human factors
- **resource-expert**: Resource abstraction and inventory management
- **ricing-expert**: System customization and visual theming

...plus the 17 core experts for CIM development.

For more advanced topics, see the CIM domain modules documentation and explore the full CIM ecosystem at https://github.com/thecowboyai/cim.