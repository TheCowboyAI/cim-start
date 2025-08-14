# CIM-Start Custom Commands

This file defines custom slash commands for easy access to CIM experts and common operations.

## Expert Commands

### /cim
**Description**: Ask the CIM Expert about architecture, mathematical foundations, or technical concepts  
**Usage**: `/cim <question>`  
**Examples**:
- `/cim what is a CIM?`
- `/cim how does content addressing work?`
- `/cim explain Category Theory in simple terms`
- `/cim show me NATS subject patterns`

**Implementation**:
```
Invoke @cim-expert with the user's question. The CIM Expert will provide detailed explanations about:
- CIM architecture and mathematical foundations
- Category Theory, Graph Theory, and IPLD concepts  
- Object Store patterns and CID usage
- NATS JetStream patterns and subject algebra
- Structure-preserving propagation
- Domain-driven event patterns and CQRS implementation
```

### /network
**Description**: Set up network topology using cim-network MCP after NATS launch
**Usage**: `/network [requirements]`
**Examples**:
- `/network` (basic topology setup)
- `/network set up secure development environment`
- `/network configure replication pathways`
- `/network what network policies are active?`

**Implementation**:
```
Invoke @network-expert with the user's request. The Network Expert will:
- Connect to cim-network MCP services
- Design network topology based on domain requirements
- Configure network security and access controls
- Set up monitoring and health check endpoints
- Validate connectivity and replication pathways
- Apply generated network configurations to CIM-Start environment
```

### /domain
**Description**: Start interactive domain creation or get domain-related guidance  
**Usage**: `/domain [description]`  
**Examples**:
- `/domain` (starts interactive session)
- `/domain create an e-commerce platform`
- `/domain help me design a customer service domain`
- `/domain what are domain boundaries?`

**Implementation**:
```
Invoke @domain-expert with the user's request. The Domain Expert will:
- Lead interactive domain discovery sessions
- Convert business requirements into CIM domain structures
- Generate complete domain.cim-graph.yaml files
- Create cim-graph library compatible events
- Validate mathematical domain structures
- Provide domain-driven design guidance
```

## Quick Reference Commands

### /architecture
**Description**: Show the CIM-Start architecture overview  
**Usage**: `/architecture`

**Implementation**:
```
Display the main architecture diagram from the README and invoke @cim-expert to explain:
- Event Store and Object Store relationship
- Self-composing links via CID references
- Mathematical foundations
- Cross-domain composition
```

### /start
**Description**: Get started guidance for new users  
**Usage**: `/start`

**Implementation**:
```
Provide a quick getting started guide:
1. Explain the template-based setup
2. Show how to use @cim-expert and @domain-expert
3. Provide next steps for domain creation
4. Reference key documentation files
```

### /examples
**Description**: Show practical examples of CIM patterns  
**Usage**: `/examples [topic]`  
**Examples**:
- `/examples` (show all available examples)
- `/examples events` (show event patterns)
- `/examples objects` (show object store patterns)
- `/examples domains` (show domain examples)

**Implementation**:
```
Display relevant examples from:
- domains/example-domain-collection-output.cim-graph.yaml
- doc/object-store-user-guide.md examples
- doc/domain-creation-mathematics.md examples
- Invoke @cim-expert for detailed explanations if needed
```

## Development Commands

### /setup
**Description**: Help with NATS and infrastructure setup  
**Usage**: `/setup [component]`  
**Examples**:
- `/setup` (general setup guidance)
- `/setup nats` (NATS JetStream setup)
- `/setup docker` (Docker compose setup)
- `/setup streams` (Stream configuration)

**Implementation**:
```
Invoke @cim-expert to provide setup guidance:
- Check current project state
- Provide appropriate setup commands
- Explain infrastructure components
- Troubleshoot common setup issues
```

### /validate
**Description**: Validate current domain configuration  
**Usage**: `/validate [domain-name]`

**Implementation**:
```
Invoke @domain-expert to:
- Check domain.cim-graph.yaml files for compliance
- Validate CIM invariants
- Check mathematical structure consistency  
- Provide improvement recommendations
```

### /schema
**Description**: Show or validate against cim-graph schemas  
**Usage**: `/schema [type]`  
**Examples**:
- `/schema` (show available schemas)
- `/schema domain` (show domain-created schema)
- `/schema graph` (show cim-graph-generated schema)

**Implementation**:
```
Display contents of agents/schemas/ files and invoke @domain-expert to explain:
- Schema structure and requirements
- cim-graph library compatibility
- Event format specifications
- Validation rules
```

## Utility Commands

### /docs
**Description**: Navigate to specific documentation  
**Usage**: `/docs [section]`  
**Examples**:
- `/docs` (list all documentation)
- `/docs object-store` (open object store guide)
- `/docs math` (open mathematical foundations)
- `/docs agents` (show agent documentation)

**Implementation**:
```
Use Read tool to display relevant documentation:
- CLAUDE.md - Development guidance
- doc/object-store-user-guide.md - Object Store patterns  
- doc/domain-creation-mathematics.md - Mathematical foundations
- doc/structure-preserving-propagation.md - Structure propagation
```

### /status  
**Description**: Show current project and domain status  
**Usage**: `/status`

**Implementation**:
```
Display current project information:
- List existing domains in domains/ directory
- Show NATS connection status (if available)
- List recent cim-graph files
- Show agent availability
- Provide next steps recommendations
```

## Command Aliases

For convenience, provide these shorter aliases:

- `/c` → `/cim`
- `/n` → `/network`
- `/d` → `/domain` 
- `/arch` → `/architecture`
- `/ex` → `/examples`
- `/help` → `/start`

## Usage Notes

1. **Expert Integration**: All expert commands automatically invoke the appropriate agent (@cim-expert, @network-expert, or @domain-expert)
2. **Context Aware**: Commands adapt to the current project state and available files
3. **Documentation Access**: Commands can read and reference all project documentation
4. **Interactive**: Domain commands can start multi-turn conversations
5. **Validation**: Commands validate inputs against project schemas when appropriate

These commands make CIM-Start expertise immediately accessible through simple slash commands while leveraging the full power of the specialized agents.