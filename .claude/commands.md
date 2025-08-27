<!-- Copyright (c) 2025 - Cowboy AI, LLC. -->

# Claude Code Commands

## Agent Commands

### @sage
Invokes the SAGE master orchestrator agent for CIM development. SAGE coordinates all 25 expert agents to provide comprehensive guidance.

**Usage**: `@sage [your request]`

**Examples**:
- `@sage Help me design a payment system`
- `@sage Create BDD scenarios for authentication`
- `@sage What's my next step in CIM development?`

### Available Expert Agents (coordinated by SAGE)
- `@bdd-expert` - Behavior-Driven Development
- `@cim-domain-expert` - CIM domain-specific architecture
- `@cim-expert` - CIM architecture and foundations
- `@cim-tea-ecs-expert` - TEA + ECS integration
- `@ddd-expert` - Domain-driven design
- `@domain-expert` - Domain creation
- `@elm-architecture-expert` - Elm Architecture patterns
- `@event-storming-expert` - Collaborative domain discovery
- `@git-expert` - Git and GitHub operations
- `@iced-ui-expert` - Iced GUI framework
- `@language-expert` - Ubiquitous language extraction
- `@nats-expert` - NATS messaging
- `@network-expert` - Network topology
- `@nix-expert` - Nix configuration
- `@qa-expert` - Quality assurance
- `@ricing-expert` - NixOS desktop aesthetics
- `@subject-expert` - CIM subject algebra
- `@tdd-expert` - Test-Driven Development

**Note**: While all agents are available, it's recommended to always start with `@sage` which will intelligently coordinate the appropriate experts for your needs.