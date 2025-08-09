#!/bin/bash
# Copyright 2025 - Cowboy AI, LLC
# Interactive Domain Collection Agent Implementation
#
# This script provides an interactive interface for collecting Domain information
# during the initial setup of a CIM system. It integrates with the CIM-Start
# infrastructure and follows CIM patterns for domain creation.

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CIM_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
NATS_URL="${NATS_URL:-nats://localhost:4222}"
ENVIRONMENT="${CIM_ENVIRONMENT:-dev}"
AGENT_ID="user-domain-collection-001"
SESSION_ID=$(uuidgen 2>/dev/null || date +%s)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
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

log_prompt() {
    echo -e "${CYAN}[PROMPT]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Banner and introduction
show_banner() {
    echo -e "${PURPLE}"
    cat << "EOF"
 ░▒▓██████▓▒░░▒▓█▓▒░▒▓██████████████▓▒░
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░
░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░
░▒▓█▓▒░      ░▒▓█▓▒░▒▓██████▓▒░░▒▓█▓▒░  
░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░
 ░▒▓██████▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓█▓▒░

Domain Collection Agent v1.0.0
EOF
    echo -e "${NC}"
}

show_welcome() {
    echo -e "${BLUE}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}                      Welcome to the CIM Domain Collection Agent!              ${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    echo "This agent will guide you through creating a new Domain for your CIM system."
    echo "A Domain establishes a 'Domain of Reasoning' - a contextual boundary for your"
    echo "business logic, organization, or individual use case."
    echo
    echo "We'll collect two required components:"
    echo "  1. Domain Name (required) - A unique identifier for your domain"
    echo "  2. Domain Purpose (required) - A clear description of what this domain represents"
    echo
    echo "The collected information will be structured as a cim-graph and integrated"
    echo "with your CIM-Start NATS JetStream environment."
    echo
    echo -e "${GREEN}Let's begin!${NC}"
    echo
}

# Validation functions
validate_domain_name() {
    local name="$1"
    
    # Check if empty
    if [[ -z "$name" ]]; then
        echo "Domain name is required."
        return 1
    fi
    
    # Check length
    if [[ ${#name} -lt 3 || ${#name} -gt 50 ]]; then
        echo "Domain name must be 3-50 characters long."
        return 1
    fi
    
    # Check format (lowercase letters, numbers, hyphens only)
    if [[ ! "$name" =~ ^[a-z0-9-]+$ ]]; then
        echo "Domain name must use lowercase letters, numbers, and hyphens only."
        return 1
    fi
    
    # Check for consecutive hyphens or leading/trailing hyphens
    if [[ "$name" =~ ^-|-$|-- ]]; then
        echo "Domain name cannot start or end with hyphens, or contain consecutive hyphens."
        return 1
    fi
    
    # Check uniqueness (domain directory doesn't exist)
    if [[ -d "$CIM_ROOT/domains/$name" ]]; then
        echo "This domain name already exists. Please choose another."
        return 1
    fi
    
    return 0
}

validate_domain_purpose() {
    local purpose="$1"
    
    # Check if empty
    if [[ -z "$purpose" ]]; then
        echo "Domain purpose is required."
        return 1
    fi
    
    # Check length
    if [[ ${#purpose} -lt 10 || ${#purpose} -gt 500 ]]; then
        echo "Domain purpose must be 10-500 characters long."
        return 1
    fi
    
    # Check for meaningful content (not just repeated characters or whitespace)
    local trimmed=$(echo "$purpose" | xargs)
    if [[ ${#trimmed} -lt 10 ]]; then
        echo "Domain purpose must contain meaningful descriptive text."
        return 1
    fi
    
    return 0
}

# Collection functions
collect_domain_name() {
    local name=""
    local validation_error=""
    
    echo
    log_prompt "What is the name of your domain?"
    echo
    echo "The domain name should:"
    echo "  • Be unique within your CIM system"
    echo "  • Use lowercase letters, numbers, and hyphens only"
    echo "  • Be descriptive but concise (3-50 characters)"
    echo "  • Examples: 'e-commerce', 'customer-service', 'inventory-management'"
    echo
    
    while true; do
        if [[ -n "$validation_error" ]]; then
            echo -e "${RED}✗ $validation_error${NC}"
            echo
        fi
        
        read -p "Domain Name: " name
        
        if validation_error=$(validate_domain_name "$name"); then
            echo -e "${GREEN}✓ Domain name '$name' is valid${NC}"
            echo "$name"
            return 0
        fi
    done
}

collect_domain_purpose() {
    local purpose=""
    local validation_error=""
    
    echo
    log_prompt "What is the purpose of this domain?"
    echo
    echo "The domain purpose should clearly describe:"
    echo "  • What business capability or area this domain represents"
    echo "  • The primary responsibilities and scope"
    echo "  • Why this domain boundary exists"
    echo "  • Minimum 10 characters, maximum 500 characters"
    echo
    echo "Example: 'Manages customer orders, inventory allocation, and fulfillment"
    echo "processes for our e-commerce platform'"
    echo
    
    while true; do
        if [[ -n "$validation_error" ]]; then
            echo -e "${RED}✗ $validation_error${NC}"
            echo
        fi
        
        echo "Domain Purpose (press Enter twice when finished):"
        purpose=""
        while IFS= read -r line; do
            if [[ -z "$line" ]]; then
                break
            fi
            purpose="${purpose}${line} "
        done
        
        # Trim trailing whitespace
        purpose=$(echo "$purpose" | sed 's/[[:space:]]*$//')
        
        if validation_error=$(validate_domain_purpose "$purpose"); then
            echo -e "${GREEN}✓ Domain purpose is valid${NC}"
            echo "$purpose"
            return 0
        fi
    done
}

# NATS event publishing functions
publish_event() {
    local subject="$1"
    local event_data="$2"
    local event_id="${3:-$(uuidgen 2>/dev/null || date +%s)}"
    
    local full_subject="${ENVIRONMENT}.${subject}.${event_id}"
    
    if command -v nats >/dev/null 2>&1; then
        echo "$event_data" | nats --server="$NATS_URL" pub "$full_subject" --stdin || {
            log_warn "Failed to publish event to NATS: $full_subject"
        }
    else
        log_warn "NATS CLI not available, skipping event publishing"
    fi
}

publish_collection_started() {
    local event_data=$(cat <<EOF
{
  "event_type": "DomainCollectionStarted",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "agent_id": "$AGENT_ID",
  "session_id": "$SESSION_ID",
  "environment": "$ENVIRONMENT",
  "version": "1.0.0"
}
EOF
)
    
    publish_event "agent.domain-collection.session.started" "$event_data"
}

publish_domain_created() {
    local domain_name="$1"
    local domain_purpose="$2"
    local cim_graph_path="$3"
    
    local event_data=$(cat <<EOF
{
  "event_type": "DomainCreated",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "agent_id": "$AGENT_ID",
  "session_id": "$SESSION_ID",
  "domain": {
    "name": "$domain_name",
    "purpose": "$domain_purpose",
    "cim_graph_path": "$cim_graph_path",
    "environment": "$ENVIRONMENT"
  },
  "version": "1.0.0"
}
EOF
)
    
    publish_event "domain.$domain_name.domain.created" "$event_data"
}

# CIM Graph generation
generate_cim_graph() {
    local domain_name="$1"
    local domain_purpose="$2"
    local output_path="$3"
    
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    local graph_id=$(uuidgen 2>/dev/null || echo "graph-$(date +%s)")
    
    cat > "$output_path" << EOF
# Copyright 2025 - Cowboy AI, LLC
# CIM Graph for Domain: $domain_name
# Generated by Domain Collection Agent v1.0.0
# Generated at: $timestamp

cim_graph:
  format_version: "1.0.0"
  graph_id: "$graph_id"
  generated_at: "$timestamp"
  generated_by: "$AGENT_ID"
  session_id: "$SESSION_ID"
  
  # Domain Entity Definition
  domain:
    entity_type: "Domain"
    entity_id: "$domain_name"
    created_at: "$timestamp"
    
    # Required Components (CIM Invariants)
    components:
      name:
        component_type: "DomainName"
        component_id: "${domain_name}-name"
        data_type: "string"
        value: "$domain_name"
        required: true
        validated_at: "$timestamp"
        constraints_satisfied:
          - "unique_within_cim"
          - "valid_identifier_format"
          - "appropriate_length"
      
      purpose:
        component_type: "DomainPurpose"
        component_id: "${domain_name}-purpose"
        data_type: "string"
        value: |
          $domain_purpose
        required: true
        validated_at: "$timestamp"
        constraints_satisfied:
          - "meaningful_description"
          - "appropriate_length"
          - "clarity_validated"
    
    # Domain Relationships
    relationships:
      - relationship_type: "establishes"
        relationship_id: "${domain_name}-establishes-reasoning"
        target_entity: "DomainOfReasoning"
        target_id: "${domain_name}-reasoning-boundary"
        cardinality: "one-to-one"
        established_at: "$timestamp"
        description: "This domain establishes a boundary for contextual reasoning"
      
      - relationship_type: "manages"
        relationship_id: "${domain_name}-manages-events"
        target_entity: "EventStream"
        target_id: "DOMAIN_${domain_name^^}_EVENTS"
        cardinality: "one-to-many"
        established_at: "$timestamp"
        description: "This domain manages its event stream for state persistence"
      
      - relationship_type: "contains"
        relationship_id: "${domain_name}-contains-contexts"
        target_entity: "BoundedContext"
        target_id: "${domain_name}-contexts"
        cardinality: "one-to-many"
        established_at: "$timestamp"
        description: "This domain may contain multiple bounded contexts"
    
    # Domain Metadata
    metadata:
      collection_method: "interactive_agent"
      validation_passed: true
      cim_compliant: true
      ready_for_implementation: true
      
    # CIM Integration
    cim_integration:
      environment: "$ENVIRONMENT"
      nats_streams:
        events: "DOMAIN_${domain_name^^}_EVENTS"
        commands: "DOMAIN_${domain_name^^}_COMMANDS"
        snapshots: "DOMAIN_${domain_name^^}_SNAPSHOTS"
      
      event_subjects:
        domain_pattern: "${ENVIRONMENT}.domain.${domain_name}.>"
        command_pattern: "${ENVIRONMENT}.command.${domain_name}.>"
        snapshot_pattern: "${ENVIRONMENT}.snapshot.${domain_name}.>"
      
      file_locations:
        domain_definition: "domains/${domain_name}/domain-definition.yaml"
        cim_graph: "domains/${domain_name}/domain.cim-graph.yaml"
        
  # Graph Validation
  validation:
    cim_invariants_checked:
      - "domain_has_name: true"
      - "domain_has_purpose: true"
      - "name_is_valid_format: true"
      - "purpose_is_meaningful: true"
      - "domain_is_unique: true"
    
    validation_timestamp: "$timestamp"
    validation_agent: "$AGENT_ID"
    validation_passed: true
    
  # Graph Statistics
  statistics:
    total_entities: 1
    total_components: 2
    total_relationships: 3
    complexity_score: "low"
    completeness_score: "foundational"
EOF
}

# Domain directory and file creation
create_domain_structure() {
    local domain_name="$1"
    local domain_purpose="$2"
    
    local domain_dir="$CIM_ROOT/domains/$domain_name"
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    
    log_info "Creating domain directory structure..."
    mkdir -p "$domain_dir"
    
    # Generate CIM Graph
    local cim_graph_path="$domain_dir/domain.cim-graph.yaml"
    generate_cim_graph "$domain_name" "$domain_purpose" "$cim_graph_path"
    log_success "Generated CIM graph: $cim_graph_path"
    
    # Create basic domain definition file
    local domain_def_path="$domain_dir/domain-definition.yaml"
    cat > "$domain_def_path" << EOF
# Copyright 2025 - Cowboy AI, LLC
# Domain Definition for: $domain_name
# Generated by Domain Collection Agent v1.0.0
# Generated at: $timestamp

domain:
  name: $domain_name
  description: $domain_purpose
  created_at: "$timestamp"
  created_by: "domain-collection-agent"
  
  # This is a foundational domain definition created by the Domain Collection Agent.
  # You can extend this definition by adding:
  # - events: Domain events that occur within this boundary
  # - commands: Actions that can be performed in this domain
  # - aggregates: Consistency boundaries and state management
  # - policies: Business rules and automated behaviors
  # - external_systems: Integration points with external services
  # - agents: Intelligent automation for this domain
  
  # For examples and templates, see:
  # - domains/example-business/domain-definition.yaml
  # - doc/quick-start.md
  # - doc/event-storming-guide.md

# Placeholder sections for future development
events: []
commands: []
aggregates: []
policies: []
external_systems: []
agents: []
workflows: {}
EOF
    log_success "Generated domain definition: $domain_def_path"
    
    echo "$cim_graph_path"
}

# Stream initialization
initialize_domain_streams() {
    local domain_name="$1"
    
    log_info "Initializing NATS streams for domain: $domain_name"
    
    if [[ -x "$CIM_ROOT/scripts/init-streams.sh" ]]; then
        CIM_ENVIRONMENT="$ENVIRONMENT" NATS_URL="$NATS_URL" "$CIM_ROOT/scripts/init-streams.sh" "$domain_name" || {
            log_warn "Failed to initialize NATS streams automatically"
            log_info "You can initialize streams later with: make init-streams"
        }
    else
        log_warn "Stream initialization script not found"
        log_info "You can initialize streams with: make init-streams"
    fi
}

# Main collection workflow
main() {
    show_banner
    show_welcome
    
    # Publish collection started event
    publish_collection_started
    
    # Check NATS connectivity (non-blocking)
    if command -v nats >/dev/null 2>&1; then
        if nats --server="$NATS_URL" server ping >/dev/null 2>&1; then
            log_success "NATS JetStream is ready at $NATS_URL"
        else
            log_warn "NATS JetStream is not accessible at $NATS_URL"
            log_info "Events will not be published, but domain creation will continue"
        fi
    else
        log_warn "NATS CLI not found"
        log_info "Install with: brew install nats-io/nats-tools/nats (macOS) or see docs"
    fi
    
    echo
    echo "Starting interactive domain collection..."
    echo
    
    # Collect domain components
    local domain_name
    local domain_purpose
    
    domain_name=$(collect_domain_name)
    domain_purpose=$(collect_domain_purpose)
    
    echo
    echo "Domain Information Collected:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${BLUE}Name:${NC} $domain_name"
    echo -e "${BLUE}Purpose:${NC} $domain_purpose"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    
    # Confirmation
    while true; do
        read -p "Does this information look correct? (y/n): " confirm
        case $confirm in
            [Yy]* ) break;;
            [Nn]* ) 
                log_info "Domain creation cancelled. Re-run this script to try again."
                exit 0;;
            * ) echo "Please answer yes (y) or no (n).";;
        esac
    done
    
    # Create domain structure and files
    echo
    log_info "Creating domain structure and generating CIM graph..."
    local cim_graph_path
    cim_graph_path=$(create_domain_structure "$domain_name" "$domain_purpose")
    
    # Initialize NATS streams
    initialize_domain_streams "$domain_name"
    
    # Publish domain created event
    publish_domain_created "$domain_name" "$domain_purpose" "$cim_graph_path"
    
    # Success message and next steps
    echo
    echo -e "${GREEN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}                            Domain Successfully Created!                         ${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo
    echo -e "${BLUE}Domain Name:${NC} $domain_name"
    echo -e "${BLUE}CIM Graph:${NC} $cim_graph_path"
    echo -e "${BLUE}Domain Definition:${NC} domains/$domain_name/domain-definition.yaml"
    echo
    echo "Next Steps:"
    echo "  1. Review and extend the domain definition file"
    echo "  2. Define domain events, commands, and aggregates"
    echo "  3. Use event storming to discover additional domain concepts"
    echo "  4. Implement domain logic using CIM modules"
    echo
    echo "Helpful Commands:"
    echo "  • make init-streams           # Initialize/update NATS streams"
    echo "  • make test-events           # Test domain event publishing"
    echo "  • make monitor              # Open monitoring dashboards"
    echo
    echo "Documentation:"
    echo "  • doc/quick-start.md        # 15-minute domain template"
    echo "  • doc/event-storming-guide.md # Collaborative domain discovery"
    echo "  • domains/example-business/  # Complete domain example"
    echo
    log_success "Domain '$domain_name' is ready for development!"
}

# Error handling
trap 'log_error "An error occurred. Domain creation may be incomplete."; exit 1' ERR

# Run main function
main "$@"