# Integration Agents

Copyright 2025 - Cowboy AI, LLC

Integration agents connect CIM domains with external systems and services.

## Agent Types

### API Connector
- **Purpose**: Connect to external REST/GraphQL APIs
- **Triggers**: Domain events requiring external data
- **Capabilities**: HTTP requests, authentication, rate limiting

### Data Synchronizer
- **Purpose**: Keep data consistent across systems
- **Triggers**: Data change events, scheduled syncs
- **Capabilities**: Bi-directional sync, conflict resolution

### Protocol Translator
- **Purpose**: Convert between different data formats/protocols
- **Triggers**: Message format mismatches
- **Capabilities**: JSON/XML/CSV conversion, schema mapping

### Service Orchestrator
- **Purpose**: Coordinate multi-service workflows
- **Triggers**: Complex business processes
- **Capabilities**: Saga patterns, compensation handling

## Configuration Examples

See `templates/` directory for complete configuration examples.