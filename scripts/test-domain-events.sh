#!/bin/bash
# Copyright 2025 - Cowboy AI, LLC
# Test domain event publishing and consumption

set -euo pipefail

# Configuration
NATS_URL="${NATS_URL:-nats://localhost:4222}"
ENVIRONMENT="${CIM_ENVIRONMENT:-dev}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Generate UUID
generate_uuid() {
    if command -v uuidgen >/dev/null 2>&1; then
        uuidgen | tr '[:upper:]' '[:lower:]'
    else
        # Fallback UUID generation
        printf '%08x-%04x-%04x-%04x-%012x\n' \
            $((RANDOM * RANDOM)) \
            $((RANDOM % 65536)) \
            $((RANDOM % 65536)) \
            $((RANDOM % 65536)) \
            $((RANDOM * RANDOM * RANDOM))
    fi
}

# Test domain event publishing
test_domain_event() {
    local domain="$1"
    local aggregate="$2" 
    local event="$3"
    local event_id=$(generate_uuid)
    local subject="${ENVIRONMENT}.domain.${domain}.${aggregate}.${event}.${event_id}"
    
    log_test "Publishing domain event to: $subject"
    
    local event_data='{
        "event_id": "'$event_id'",
        "event_type": "'$event'",
        "aggregate_type": "'$aggregate'",
        "aggregate_id": "'$(generate_uuid)'",
        "domain": "'$domain'",
        "timestamp": "'$(date -Iseconds)'",
        "version": 1,
        "data": {
            "test": true,
            "message": "Test event from cim-start"
        },
        "metadata": {
            "correlation_id": "'$(generate_uuid)'",
            "causation_id": "'$(generate_uuid)'",
            "source": "cim-start-test"
        }
    }'
    
    echo "$event_data" | nats --server="$NATS_URL" pub "$subject" --stdin
    log_info "Event published successfully"
}

# Test command publishing
test_command() {
    local domain="$1"
    local aggregate="$2"
    local action="$3"
    local subject="${ENVIRONMENT}.command.${domain}.${aggregate}.${action}"
    
    log_test "Publishing command to: $subject"
    
    local command_data='{
        "command_id": "'$(generate_uuid)'",
        "command_type": "'$action'",
        "aggregate_type": "'$aggregate'",
        "domain": "'$domain'",
        "timestamp": "'$(date -Iseconds)'",
        "data": {
            "test": true,
            "message": "Test command from cim-start"
        },
        "metadata": {
            "correlation_id": "'$(generate_uuid)'",
            "source": "cim-start-test"
        }
    }'
    
    echo "$command_data" | nats --server="$NATS_URL" pub "$subject" --stdin
    log_info "Command published successfully"
}

# Test projection update
test_projection() {
    local view="$1"
    local operation="$2"
    local subject="${ENVIRONMENT}.projection.${view}.${operation}"
    
    log_test "Publishing projection update to: $subject"
    
    local projection_data='{
        "projection_id": "'$(generate_uuid)'",
        "view_name": "'$view'",
        "operation": "'$operation'",
        "timestamp": "'$(date -Iseconds)'",
        "data": {
            "test": true,
            "message": "Test projection from cim-start"
        }
    }'
    
    echo "$projection_data" | nats --server="$NATS_URL" pub "$subject" --stdin
    log_info "Projection update published successfully"
}

# Test saga event
test_saga() {
    local process="$1"
    local event="$2"
    local subject="${ENVIRONMENT}.saga.${process}.${event}"
    
    log_test "Publishing saga event to: $subject"
    
    local saga_data='{
        "saga_id": "'$(generate_uuid)'",
        "process_name": "'$process'",
        "event_type": "'$event'",
        "timestamp": "'$(date -Iseconds)'",
        "data": {
            "test": true,
            "message": "Test saga event from cim-start"
        }
    }'
    
    echo "$saga_data" | nats --server="$NATS_URL" pub "$subject" --stdin
    log_info "Saga event published successfully"
}

# Test snapshot
test_snapshot() {
    local domain="$1"
    local aggregate="$2"
    local aggregate_id=$(generate_uuid)
    local subject="${ENVIRONMENT}.snapshot.${domain}.${aggregate}.${aggregate_id}"
    
    log_test "Publishing snapshot to: $subject"
    
    local snapshot_data='{
        "aggregate_id": "'$aggregate_id'",
        "aggregate_type": "'$aggregate'",
        "domain": "'$domain'",
        "version": 5,
        "timestamp": "'$(date -Iseconds)'",
        "state": {
            "test": true,
            "message": "Test snapshot from cim-start",
            "current_state": "active"
        }
    }'
    
    echo "$snapshot_data" | nats --server="$NATS_URL" pub "$subject" --stdin
    log_info "Snapshot published successfully"
}

# Subscribe to events for testing
test_subscription() {
    local pattern="$1"
    
    log_test "Testing subscription to pattern: $pattern"
    log_info "Listening for 5 seconds..."
    
    timeout 5 nats --server="$NATS_URL" sub "$pattern" --translate-date || true
    log_info "Subscription test complete"
}

# Main test function
main() {
    log_info "CIM Domain Event Testing"
    log_info "Environment: $ENVIRONMENT"
    log_info "NATS URL: $NATS_URL"
    
    # Check NATS connectivity
    if ! nats --server="$NATS_URL" server ping >/dev/null 2>&1; then
        log_error "Cannot connect to NATS server at $NATS_URL"
        exit 1
    fi
    
    log_info "NATS server is accessible"
    echo
    
    # Test domain events
    log_info "=== Testing Domain Events ==="
    test_domain_event "sales" "order" "created"
    test_domain_event "sales" "order" "paid"
    test_domain_event "inventory" "product" "created" 
    test_domain_event "customer" "customer" "registered"
    echo
    
    # Test commands
    log_info "=== Testing Commands ==="
    test_command "sales" "order" "create"
    test_command "sales" "order" "ship"
    test_command "inventory" "product" "update"
    echo
    
    # Test projections
    log_info "=== Testing Projections ==="
    test_projection "order-summary" "update"
    test_projection "customer-profile" "refresh"
    echo
    
    # Test sagas
    log_info "=== Testing Sagas ==="
    test_saga "order-fulfillment" "started"
    test_saga "payment-processing" "completed"
    echo
    
    # Test snapshots
    log_info "=== Testing Snapshots ==="
    test_snapshot "sales" "order"
    test_snapshot "customer" "customer"
    echo
    
    # Show stream information
    log_info "=== Stream Status ==="
    nats --server="$NATS_URL" stream list
    echo
    
    # Test subscriptions
    log_info "=== Testing Subscriptions ==="
    log_info "To test subscriptions, run in another terminal:"
    echo "  # Listen to all domain events"
    echo "  nats sub '$ENVIRONMENT.domain.>'"
    echo
    echo "  # Listen to sales domain events" 
    echo "  nats sub '$ENVIRONMENT.domain.sales.>'"
    echo
    echo "  # Listen to order events across all domains"
    echo "  nats sub '$ENVIRONMENT.domain.*.order.>'"
    echo
    echo "  # Listen to all commands"
    echo "  nats sub '$ENVIRONMENT.command.>'"
    echo
    
    log_info "Test completed successfully!"
}

# Run main function
main "$@"