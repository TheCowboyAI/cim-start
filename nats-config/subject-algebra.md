# CIM Domain Subject Algebra

Copyright 2025 - Cowboy AI, LLC

## Subject Structure

CIM uses a hierarchical subject structure to organize domain events, commands, and projections within NATS JetStream.

### Core Subject Pattern

```
{environment}.{domain}.{aggregate}.{event_type}.{event_id}
```

### Subject Components

- **environment**: `dev`, `staging`, `prod`
- **domain**: Domain name (e.g., `sales`, `inventory`, `customer`)
- **aggregate**: Aggregate root name (e.g., `order`, `customer`, `product`)
- **event_type**: Event name in past tense (e.g., `created`, `updated`, `shipped`)
- **event_id**: Unique event identifier (UUID)

## Subject Categories

### 1. Domain Events
Events that have occurred in the domain.

**Pattern**: `{env}.domain.{domain}.{aggregate}.{event}.{id}`

**Examples**:
```
prod.domain.sales.order.created.550e8400-e29b-41d4-a716-446655440000
prod.domain.sales.order.shipped.550e8400-e29b-41d4-a716-446655440001
prod.domain.inventory.product.created.550e8400-e29b-41d4-a716-446655440002
prod.domain.customer.customer.registered.550e8400-e29b-41d4-a716-446655440003
```

### 2. Commands
Actions requested to be performed.

**Pattern**: `{env}.command.{domain}.{aggregate}.{action}`

**Examples**:
```
prod.command.sales.order.create
prod.command.sales.order.ship
prod.command.inventory.product.update
prod.command.customer.customer.register
```

### 3. Projections
Read model updates and queries.

**Pattern**: `{env}.projection.{view_name}.{operation}`

**Examples**:
```
prod.projection.order-summary.update
prod.projection.customer-profile.refresh
prod.projection.inventory-levels.sync
```

### 4. Snapshots
Aggregate state snapshots for event sourcing.

**Pattern**: `{env}.snapshot.{domain}.{aggregate}.{aggregate_id}`

**Examples**:
```
prod.snapshot.sales.order.550e8400-e29b-41d4-a716-446655440000
prod.snapshot.inventory.product.550e8400-e29b-41d4-a716-446655440001
```

### 5. Saga/Process Manager Events
Workflow and process coordination.

**Pattern**: `{env}.saga.{process_name}.{event}`

**Examples**:
```
prod.saga.order-fulfillment.started
prod.saga.order-fulfillment.completed
prod.saga.payment-processing.failed
```

## Stream Configuration

### Event Streams
Each domain gets its own event stream for strong consistency.

**Stream Name**: `DOMAIN_{DOMAIN_NAME}_EVENTS`
**Subjects**: `*.domain.{domain_name}.>`

Example:
```
Stream: DOMAIN_SALES_EVENTS
Subjects: *.domain.sales.>
```

### Command Streams
Commands are typically short-lived and interest-based.

**Stream Name**: `DOMAIN_{DOMAIN_NAME}_COMMANDS`
**Subjects**: `*.command.{domain_name}.>`
**Retention**: Interest-based, 1 hour max age

### Projection Streams
Read model updates and maintenance.

**Stream Name**: `PROJECTIONS`
**Subjects**: `*.projection.>`
**Retention**: Limits-based, last value per subject

## Subject Wildcards for Subscriptions

### All Events for a Domain
```
*.domain.sales.>
```

### All Events for an Aggregate
```
*.domain.sales.order.>
```

### Specific Event Type Across All Aggregates
```
*.domain.sales.*.created.*
```

### All Commands for a Domain
```
*.command.sales.>
```

### All Projections
```
*.projection.>
```

## Environment-Specific Configuration

### Development
- **Subject Prefix**: `dev.`
- **Retention**: Short (1 day)
- **Replication**: 1

### Staging
- **Subject Prefix**: `staging.`
- **Retention**: Medium (7 days)
- **Replication**: 1

### Production
- **Subject Prefix**: `prod.`
- **Retention**: Long (30+ days)
- **Replication**: 3

## Example Domain: E-Commerce

```
# Customer Domain Events
prod.domain.customer.customer.registered.{uuid}
prod.domain.customer.customer.updated.{uuid}
prod.domain.customer.customer.deactivated.{uuid}

# Sales Domain Events  
prod.domain.sales.order.created.{uuid}
prod.domain.sales.order.paid.{uuid}
prod.domain.sales.order.shipped.{uuid}
prod.domain.sales.order.delivered.{uuid}
prod.domain.sales.order.cancelled.{uuid}

# Inventory Domain Events
prod.domain.inventory.product.created.{uuid}
prod.domain.inventory.product.updated.{uuid}
prod.domain.inventory.stock.reserved.{uuid}
prod.domain.inventory.stock.released.{uuid}
prod.domain.inventory.stock.depleted.{uuid}

# Commands
prod.command.customer.customer.register
prod.command.sales.order.create
prod.command.sales.order.ship
prod.command.inventory.product.create

# Projections
prod.projection.customer-summary.update
prod.projection.order-history.update
prod.projection.inventory-levels.sync

# Sagas
prod.saga.order-fulfillment.started
prod.saga.order-fulfillment.payment-processed
prod.saga.order-fulfillment.shipped
prod.saga.order-fulfillment.completed
```

## Best Practices

### 1. Consistent Naming
- Use lowercase with hyphens for multi-word names
- Use past-tense for events (`created`, not `create`)
- Use imperative for commands (`create`, not `creating`)

### 2. Logical Grouping
- Group related events under the same aggregate
- Use domain boundaries to separate concerns
- Keep projection updates separate from domain events

### 3. Scalability
- Use domain-specific streams for horizontal scaling
- Implement partitioning based on aggregate IDs
- Consider subject-based sharding for high-volume domains

### 4. Security
- Use subject-based permissions
- Separate read/write access by subject patterns
- Implement environment isolation

### 5. Monitoring
- Monitor per-subject message rates
- Track consumer lag by domain
- Alert on subject pattern anomalies

This subject algebra provides the foundation for organizing domain events within NATS JetStream, enabling clear separation of concerns while maintaining discoverability and scalability.