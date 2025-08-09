#!/bin/bash
# Copyright 2025 - Cowboy AI, LLC
# Test script for Domain Collection Agent NATS integration

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

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

test_nats_connectivity() {
    log_info "Testing NATS connectivity..."
    
    if command -v nats >/dev/null 2>&1; then
        if nats --server="$NATS_URL" server ping >/dev/null 2>&1; then
            log_info "✓ NATS server is accessible at $NATS_URL"
            return 0
        else
            log_error "✗ NATS server is not accessible at $NATS_URL"
            return 1
        fi
    else
        log_warn "✗ NATS CLI not found. Install with: brew install nats-io/nats-tools/nats"
        return 1
    fi
}

test_domain_collection_events() {
    log_info "Testing domain collection event publishing..."
    
    local test_session_id="test-session-$(date +%s)"
    local test_subject="${ENVIRONMENT}.agent.domain-collection.session.started.${test_session_id}"
    
    local test_event=$(cat <<EOF
{
  "event_type": "DomainCollectionStarted",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "agent_id": "test-domain-collection-agent",
  "session_id": "$test_session_id",
  "environment": "$ENVIRONMENT",
  "version": "1.0.0"
}
EOF
)
    
    if echo "$test_event" | nats --server="$NATS_URL" pub "$test_subject" --stdin 2>/dev/null; then
        log_info "✓ Successfully published domain collection test event"
        log_info "  Subject: $test_subject"
        return 0
    else
        log_error "✗ Failed to publish domain collection test event"
        return 1
    fi
}

test_domain_created_events() {
    log_info "Testing domain created event publishing..."
    
    local test_domain_name="test-domain-$(date +%s)"
    local test_event_id="event-$(date +%s)"
    local test_subject="${ENVIRONMENT}.domain.${test_domain_name}.domain.created.${test_event_id}"
    
    local test_event=$(cat <<EOF
{
  "event_type": "DomainCreated",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "agent_id": "test-domain-collection-agent",
  "session_id": "test-session-123",
  "domain": {
    "name": "$test_domain_name",
    "purpose": "Test domain created by the test script for validation purposes",
    "cim_graph_path": "domains/$test_domain_name/domain.cim-graph.yaml",
    "environment": "$ENVIRONMENT"
  },
  "version": "1.0.0"
}
EOF
)
    
    if echo "$test_event" | nats --server="$NATS_URL" pub "$test_subject" --stdin 2>/dev/null; then
        log_info "✓ Successfully published domain created test event"
        log_info "  Subject: $test_subject"
        return 0
    else
        log_error "✗ Failed to publish domain created test event"
        return 1
    fi
}

test_stream_existence() {
    log_info "Testing required streams existence..."
    
    local streams_exist=true
    local required_streams=("PROJECTIONS" "SAGAS")
    
    for stream in "${required_streams[@]}"; do
        if nats --server="$NATS_URL" stream info "$stream" >/dev/null 2>&1; then
            log_info "✓ Stream $stream exists"
        else
            log_warn "✗ Stream $stream does not exist"
            streams_exist=false
        fi
    done
    
    if $streams_exist; then
        return 0
    else
        log_warn "Some required streams are missing. Run 'make init-streams' to create them."
        return 1
    fi
}

test_agent_script_existence() {
    log_info "Testing domain collection agent script..."
    
    local script_path="./agents/user/domain-collection-agent.sh"
    
    if [[ -f "$script_path" ]]; then
        if [[ -x "$script_path" ]]; then
            log_info "✓ Domain collection agent script exists and is executable"
            return 0
        else
            log_error "✗ Domain collection agent script exists but is not executable"
            log_info "  Fix with: chmod +x $script_path"
            return 1
        fi
    else
        log_error "✗ Domain collection agent script not found at $script_path"
        return 1
    fi
}

test_agent_configuration() {
    log_info "Testing domain collection agent configuration..."
    
    local config_path="./agents/user/domain-collection-agent.yaml"
    
    if [[ -f "$config_path" ]]; then
        log_info "✓ Domain collection agent configuration exists"
        return 0
    else
        log_error "✗ Domain collection agent configuration not found at $config_path"
        return 1
    fi
}

main() {
    echo -e "${BLUE}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}                      Domain Collection Agent Integration Test                   ${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    echo "Environment: $ENVIRONMENT"
    echo "NATS URL: $NATS_URL"
    echo
    
    local tests_passed=0
    local total_tests=0
    
    # Run tests
    tests=(
        "test_agent_script_existence"
        "test_agent_configuration" 
        "test_nats_connectivity"
        "test_stream_existence"
        "test_domain_collection_events"
        "test_domain_created_events"
    )
    
    for test in "${tests[@]}"; do
        echo
        total_tests=$((total_tests + 1))
        if $test; then
            tests_passed=$((tests_passed + 1))
        fi
    done
    
    echo
    echo -e "${BLUE}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}                                Test Results                                     ${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    echo "Tests Passed: $tests_passed/$total_tests"
    
    if [[ $tests_passed -eq $total_tests ]]; then
        log_info "🎉 All tests passed! Domain Collection Agent is ready to use."
        echo
        echo "Next steps:"
        echo "  • Run 'make create-domain' to create your first domain"
        echo "  • Or run './agents/user/domain-collection-agent.sh' directly"
        echo "  • Monitor events with 'make watch-events'"
        return 0
    else
        log_error "Some tests failed. Please address the issues above."
        echo
        echo "Common fixes:"
        echo "  • Start NATS: make start"
        echo "  • Initialize streams: make init-streams"
        echo "  • Fix permissions: chmod +x ./agents/user/domain-collection-agent.sh"
        return 1
    fi
}

main "$@"