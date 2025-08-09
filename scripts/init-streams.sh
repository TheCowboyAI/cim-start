#!/bin/bash
# Copyright 2025 - Cowboy AI, LLC
# Initialize NATS JetStream streams for CIM domain events

set -euo pipefail

# Configuration
NATS_URL="${NATS_URL:-nats://localhost:4222}"
ENVIRONMENT="${CIM_ENVIRONMENT:-dev}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Wait for NATS to be ready
wait_for_nats() {
    log_info "Waiting for NATS server to be ready..."
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if nats --server="$NATS_URL" server ping >/dev/null 2>&1; then
            log_info "NATS server is ready"
            return 0
        fi
        
        attempt=$((attempt + 1))
        log_warn "NATS not ready yet, attempt $attempt/$max_attempts"
        sleep 2
    done
    
    log_error "NATS server failed to become ready after $max_attempts attempts"
    exit 1
}

# Create a domain event stream
create_domain_stream() {
    local domain_name="$1"
    local stream_name="DOMAIN_${domain_name^^}_EVENTS"
    local subjects="${ENVIRONMENT}.domain.${domain_name}.>"
    
    log_info "Creating domain stream: $stream_name"
    
    nats --server="$NATS_URL" stream add "$stream_name" \
        --subjects="$subjects" \
        --storage=file \
        --retention=limits \
        --max-msgs=-1 \
        --max-bytes=10GB \
        --max-age=30d \
        --max-consumers=-1 \
        --max-msg-size=8MB \
        --discard=old \
        --dupe-window=2m \
        --replicas=1 \
        --no-allow-rollup || {
        log_warn "Stream $stream_name may already exist or failed to create"
    }
}

# Create a command stream  
create_command_stream() {
    local domain_name="$1"
    local stream_name="DOMAIN_${domain_name^^}_COMMANDS"
    local subjects="${ENVIRONMENT}.command.${domain_name}.>"
    
    log_info "Creating command stream: $stream_name"
    
    nats --server="$NATS_URL" stream add "$stream_name" \
        --subjects="$subjects" \
        --storage=memory \
        --retention=interest \
        --max-msgs=10000 \
        --max-bytes=100MB \
        --max-age=1h \
        --max-consumers=-1 \
        --max-msg-size=1MB \
        --discard=old \
        --dupe-window=30s \
        --replicas=1 || {
        log_warn "Stream $stream_name may already exist or failed to create"
    }
}

# Create projection stream
create_projection_stream() {
    log_info "Creating projections stream"
    
    nats --server="$NATS_URL" stream add "PROJECTIONS" \
        --subjects="${ENVIRONMENT}.projection.>" \
        --storage=file \
        --retention=limits \
        --max-msgs=-1 \
        --max-bytes=5GB \
        --max-age=7d \
        --max-consumers=-1 \
        --max-msg-size=4MB \
        --discard=old \
        --dupe-window=1m \
        --replicas=1 \
        --allow-rollup || {
        log_warn "Stream PROJECTIONS may already exist or failed to create"
    }
}

# Create saga stream
create_saga_stream() {
    log_info "Creating saga/process stream"
    
    nats --server="$NATS_URL" stream add "SAGAS" \
        --subjects="${ENVIRONMENT}.saga.>" \
        --storage=file \
        --retention=limits \
        --max-msgs=1000000 \
        --max-bytes=2GB \
        --max-age=7d \
        --max-consumers=-1 \
        --max-msg-size=2MB \
        --discard=old \
        --dupe-window=1m \
        --replicas=1 || {
        log_warn "Stream SAGAS may already exist or failed to create"
    }
}

# Create snapshot stream
create_snapshot_stream() {
    local domain_name="$1"
    local stream_name="DOMAIN_${domain_name^^}_SNAPSHOTS"
    local subjects="${ENVIRONMENT}.snapshot.${domain_name}.>"
    
    log_info "Creating snapshot stream: $stream_name"
    
    nats --server="$NATS_URL" stream add "$stream_name" \
        --subjects="$subjects" \
        --storage=file \
        --retention=limits \
        --max-msgs=-1 \
        --max-bytes=5GB \
        --max-age=90d \
        --max-consumers=-1 \
        --max-msg-size=8MB \
        --discard=old \
        --dupe-window=5m \
        --replicas=1 \
        --allow-rollup || {
        log_warn "Stream $stream_name may already exist or failed to create"
    }
}

# Initialize streams for a domain
init_domain_streams() {
    local domain_name="$1"
    
    log_info "Initializing streams for domain: $domain_name"
    
    create_domain_stream "$domain_name"
    create_command_stream "$domain_name"  
    create_snapshot_stream "$domain_name"
}

# Main function
main() {
    log_info "CIM NATS JetStream Initialization"
    log_info "Environment: $ENVIRONMENT"
    log_info "NATS URL: $NATS_URL"
    
    # Wait for NATS to be ready
    wait_for_nats
    
    # Get domain names from arguments or discover from domains directory
    local domains=("$@")
    
    if [ ${#domains[@]} -eq 0 ]; then
        log_info "No domains specified, discovering from domains directory..."
        
        if [ -d "/domains" ]; then
            for domain_dir in /domains/*/; do
                if [ -d "$domain_dir" ]; then
                    domain_name=$(basename "$domain_dir")
                    domains+=("$domain_name")
                fi
            done
        fi
        
        if [ -d "./domains" ]; then
            for domain_dir in ./domains/*/; do
                if [ -d "$domain_dir" ]; then
                    domain_name=$(basename "$domain_dir")
                    domains+=("$domain_name")
                fi
            done
        fi
    fi
    
    # Default to example-business if no domains found
    if [ ${#domains[@]} -eq 0 ]; then
        log_warn "No domains found, using default: example-business"
        domains=("example-business")
    fi
    
    # Create global streams
    create_projection_stream
    create_saga_stream
    
    # Create domain-specific streams
    for domain in "${domains[@]}"; do
        init_domain_streams "$domain"
    done
    
    # Show stream status
    log_info "Stream initialization complete. Current streams:"
    nats --server="$NATS_URL" stream list
    
    log_info "Subjects pattern for $ENVIRONMENT environment:"
    log_info "  Domain Events: ${ENVIRONMENT}.domain.<domain>.<aggregate>.<event>.<id>"
    log_info "  Commands:      ${ENVIRONMENT}.command.<domain>.<aggregate>.<action>"
    log_info "  Projections:   ${ENVIRONMENT}.projection.<view>.<operation>"
    log_info "  Sagas:         ${ENVIRONMENT}.saga.<process>.<event>"
    log_info "  Snapshots:     ${ENVIRONMENT}.snapshot.<domain>.<aggregate>.<id>"
}

# Run main function with all arguments
main "$@"