# CIM Agents Integration Guide

Copyright 2025 - Cowboy AI, LLC

## Overview

CIM agents are composable, event-driven modules that enhance domain workflows with intelligent automation. Unlike traditional subagent hierarchies, CIM agents operate as autonomous domain participants that respond to events and execute commands within your business context.

## Agent Architecture

### Core Principles

1. **Event-Driven**: Agents respond to domain events through NATS messaging
2. **Composable**: Mix and match agents based on domain needs
3. **Autonomous**: Each agent operates independently within defined boundaries
4. **Domain-Aware**: Agents understand and participate in business workflows

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

## Getting Started

### 1. Choose Agent Templates

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

1. Start with system agents for monitoring
2. Add integration agents for external systems
3. Implement AI agents for intelligent decision making
4. Create user agents for workflow automation
5. Compose agents into complex workflows

For more advanced topics, see the CIM domain modules documentation and explore the full CIM ecosystem at https://github.com/thecowboyai/cim.