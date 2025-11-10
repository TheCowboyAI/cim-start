# Step 6: Domain-First Development

**Time Required**: 6-8 weeks

**Prerequisites**:
- [Step 1: Clone and Initialize](01-clone-and-initialize.md) ✅
- [Step 2: Define Purpose](02-define-purpose.md) ✅
- [Step 3: Create Organization](03-create-organization.md) ✅
- [Step 4: Add People](04-add-people.md) ✅
- [Step 5: Choose Your Path](05-choose-your-path.md) - **Chose Path A** ✅

---

**Note**: This guide is for the **Domain-First** path. If you chose Infrastructure-First, see [Infrastructure Setup Guide](06-infrastructure-setup.md) instead.

---

## Overview of Domain-First Workflow

### What Does Domain-First Mean?

Domain-First development means building your conceptual models and business logic BEFORE setting up infrastructure. You're creating a "prototypical space" - a geometric representation of your domain that exists independently of any technical implementation.

Think of it like designing a city before laying pipes. You understand neighborhoods (bounded contexts), traffic patterns (event flows), and zoning (aggregates) before breaking ground.

### Why Start with Domain Before Infrastructure?

1. **Pure Domain Logic**: No infrastructure concerns pollute your model
2. **Faster Iteration**: Change models without redeploying infrastructure
3. **Better Understanding**: Focus on WHAT before HOW
4. **Cost Effective**: No cloud resources during discovery phase
5. **Team Alignment**: Business experts can participate without technical barriers

### What Will You Accomplish?

By the end of this step, you'll have:
- A complete domain model derived from external observations
- Validated aggregates with state machines
- Event-sourced projections tested locally
- A prototypical space representing your domain geometrically
- Clear transition plan to infrastructure deployment

---

## Phase 1: OBSERVE External Systems (Weeks 1-2)

### The Observation Principle

**OBSERVE without COUPLING**. You're a scientist studying organisms in their natural habitat. Document what you see without disturbing the ecosystem.

### 1.1 Identify External Systems from purpose.yaml

```bash
# Extract external dependencies
cat purpose.yaml | grep -A 20 "external_systems:"

# Example output for mortgage domain:
# external_systems:
#   - name: "Equifax Credit Bureau API"
#   - name: "Property Valuation System"
#   - name: "Legacy Underwriting Database"
```

### 1.2 Observe APIs (Schemas Without Integration)

Create observation files:

```yaml
# observations/external/equifax_api.yaml
api_observation:
  observed_date: "2024-11-10"
  base_url: "https://api.equifax.com/v1"
  
  observed_endpoints:
    - path: "/credit-report"
      method: GET
      observed_schema:
        request:
          ssn: "string"
          dob: "date"
          consent_token: "string"
        response:
          credit_score: "integer[300-850]"
          tradelines: "array"
          inquiries: "array"
          
  observed_patterns:
    - "Uses OAuth2 for authentication"
    - "Rate limited to 100 requests/minute"
    - "Scores updated daily at 2 AM EST"
    
  observed_terminology:
    - "tradeline": "Individual credit account"
    - "hard_inquiry": "Credit check that affects score"
    - "utilization": "Credit used vs available"
```

**SAGE Command**:
```bash
@sage Observe API at https://sandbox.equifax.com/v1 and document schema
```

### 1.3 Observe Databases (Schemas Without Coupling)

```yaml
# observations/external/legacy_loan_db.yaml
database_observation:
  observed_date: "2024-11-10"
  type: "PostgreSQL"
  
  observed_tables:
    applications:
      columns:
        - application_id: "UUID PRIMARY KEY"
        - borrower_ssn: "VARCHAR(9)"
        - property_address: "TEXT"
        - loan_amount: "DECIMAL(12,2)"
        - status: "ENUM('pending','approved','denied')"
        - created_at: "TIMESTAMP"
        
  observed_relationships:
    - "applications.borrower_ssn -> borrowers.ssn"
    - "applications.property_id -> properties.id"
    
  observed_constraints:
    - "loan_amount must be > 0"
    - "ltv_ratio cannot exceed 0.97"
    
  observed_patterns:
    - "Status changes trigger stored procedures"
    - "Soft deletes via deleted_at column"
    - "Audit trail in separate schema"
```

**SAGE Command**:
```bash
@sage Observe database schema from connection string (schema only, no data)
```

### 1.4 Capture Observation Manifest

```yaml
# observations/manifest.yaml
observation_session:
  domain: "mortgage_underwriting"
  observer: "team_name"
  period: "2024-11-10 to 2024-11-24"
  
  external_systems:
    apis:
      - equifax_api
      - property_valuation_api
      - income_verification_api
    databases:
      - legacy_loan_system
      - borrower_management_db
    documents:
      - fannie_mae_guide_v2024
      - freddie_mac_standards
      
  observations_collected:
    schemas: 12
    sample_responses: 47
    terminology_entries: 156
    business_rules: 89
    workflow_patterns: 7
    
  key_insights:
    - "Credit score is referenced but never owned"
    - "Property valuation expires and must be refreshed"
    - "Underwriting follows strict sequential stages"
```

---

## Phase 2: REFINE Through Recursion (Weeks 3-4, n=6 iterations)

### The TRM Principle

From arXiv:2510.04871v1: "Each iteration extracts increasingly abstract patterns while maintaining connection to concrete observations."

### Why n=6 Iterations?

Research shows 6 iterations optimally balances:
- **Convergence**: Patterns stabilize by iteration 4-5
- **Overfitting**: Beyond 6 risks over-specialization
- **Cognitive Load**: Teams can track 6 refinements effectively

### Iteration 1: Extract Nouns (Entities)

```yaml
# refinements/iteration_1_nouns.yaml
extracted_nouns:
  from_apis:
    - CreditScore
    - TradeLine
    - CreditInquiry
    - PropertyValuation
    - IncomeVerification
    
  from_databases:
    - Application
    - Borrower
    - Property
    - LoanProduct
    - Underwriter
    
  from_documents:
    - DebtToIncomeRatio
    - LoanToValueRatio
    - QualifiedMortgage
    - AppraisalReport
    
ubiquitous_language:
  CreditProfile: "Complete credit history including score and tradelines"
  CollateralProperty: "Property securing the loan"
  UnderwritingDecision: "Approval, denial, or conditional approval"
```

**SAGE Command**:
```bash
@sage Extract entities from observations (iteration 1)
```

### Iteration 2: Find Relationships

```yaml
# refinements/iteration_2_relationships.yaml
relationships:
  ownership:
    - "Application OWNS UnderwritingDecision"
    - "Borrower OWNS IncomeProfile"
    - "Property OWNS Appraisal"
    
  reference:
    - "Application REFERENCES CreditScore"
    - "UnderwritingDecision REFERENCES Guidelines"
    - "Appraisal REFERENCES MarketData"
    
  temporal:
    - "CreditScore EXPIRES_AFTER 30 days"
    - "Appraisal VALID_FOR 120 days"
    - "IncomeVerification REQUIRES 2 years history"
```

**SAGE Command**:
```bash
@sage Identify relationships between entities (iteration 2)
```

### Iteration 4: Group into Contexts

```yaml
# refinements/iteration_4_contexts.yaml
candidate_contexts:
  application_management:
    entities: [Application, Borrower, CoBorrower]
    behaviors: [submit, withdraw, update]
    
  risk_assessment:
    entities: [CreditProfile, IncomeProfile, DebtRatios]
    behaviors: [assess, calculate, score]
    external_refs: [CreditScore, EmploymentData]
    
  collateral_valuation:
    entities: [Property, Appraisal, MarketComps]
    behaviors: [evaluate, compare, adjust]
    external_refs: [PropertyData, MarketTrends]
    
  underwriting_decision:
    entities: [UnderwritingWorkflow, Decision, Conditions]
    behaviors: [review, approve, deny, condition]
```

**SAGE Command**:
```bash
@sage Group entities into bounded contexts (iteration 4)
```

### Iteration 6: Validate Completeness

```yaml
# refinements/iteration_6_validation.yaml
completeness_check:
  all_observations_mapped: true
  all_terms_defined: true
  all_behaviors_assigned: true
  
  coverage_matrix:
    equifax_api: [CreditProfile, RiskAssessment]
    property_api: [CollateralValuation]
    legacy_db: [Application, Historical]
    guidelines: [Underwriting, Compliance]
    
  gaps_identified:
    - "No fraud detection context identified"
    - "Compliance reporting not fully mapped"
    
  conceptual_space_ready: true
```

**SAGE Command**:
```bash
@sage Validate refinement completeness (iteration 6)
```

---

## Phase 3: DISTILL into DDD (Weeks 5-6, T=3 levels)

### T=3 Supervision Levels Explained

1. **Strategic (T=1)**: Overall architecture and context boundaries
2. **Tactical (T=2)**: Aggregates, entities, and value objects
3. **Operational (T=3)**: Events, commands, and workflows

### Strategic Level: Extract Bounded Contexts

```yaml
# ddd_model/bounded_contexts.yaml
bounded_contexts:
  - name: "Application"
    responsibility: "Manage loan application lifecycle"
    aggregates: [Application]
    events: [ApplicationSubmitted, ApplicationUpdated, ApplicationWithdrawn]
    upstream: []
    downstream: ["Underwriting", "Risk"]

  - name: "Underwriting"
    responsibility: "Make lending decisions"
    aggregates: [UnderwritingCase]
    events: [UnderwritingStarted, DecisionMade, ConditionsAdded]
    upstream: ["Application", "Risk"]
    downstream: ["Closing"]

  - name: "Risk"
    responsibility: "Assess creditworthiness"
    aggregates: [RiskProfile]
    events: [CreditScoreObtained, IncomeVerified, RatiosCalculated]
    upstream: ["Application"]
    downstream: ["Underwriting"]
```

**SAGE Command**:
```bash
@sage Extract bounded contexts from refinements (Strategic level)
```

### Tactical Level: Extract Aggregates

```yaml
# ddd_model/aggregates/application.yaml
aggregate:
  name: "Application"
  root_entity: "ApplicationId"
  
  entities:
    - Borrower
    - CoBorrower (optional)
    - PropertyReference
    
  value_objects:
    - LoanAmount
    - LoanPurpose
    - ApplicationStatus
    
  invariants:
    - "Loan amount must be positive"
    - "At least one borrower required"
    - "Property must be identified"
    
  state_machine:
    states: [Draft, Submitted, InReview, Approved, Denied, Withdrawn]
    initial_state: Draft
    
  commands:
    - SubmitApplication
    - AddCoBorrower
    - UpdateLoanAmount
    - WithdrawApplication
    
  events:
    - ApplicationCreated
    - ApplicationSubmitted
    - CoBorrowerAdded
    - LoanAmountUpdated
    - ApplicationWithdrawn
```

**SAGE Command**:
```bash
@sage Generate aggregates from bounded contexts (Tactical level)
```

### Operational Level: Extract Domain Events

```yaml
# ddd_model/events/application_events.yaml
events:
  ApplicationSubmitted:
    aggregate: Application
    properties:
      application_id: ApplicationId
      borrower: BorrowerInfo
      loan_amount: MoneyAmount
      property: PropertyReference
      submitted_at: DateTime
      submitted_by: PersonId
      
  CreditScoreObtained:
    aggregate: RiskProfile
    properties:
      application_id: ApplicationId
      credit_score: CreditScoreReference
      bureau: CreditBureau
      obtained_at: DateTime
      expires_at: DateTime
```

**SAGE Command**:
```bash
@sage Create event catalog from aggregates (Operational level)
```

---

## Phase 4: Local Testing with NATS (Weeks 6-7)

### Setup Local NATS

```yaml
# docker-compose.yaml
version: '3.8'

services:
  nats:
    image: nats:2.10-alpine
    container_name: cim_local_nats
    ports:
      - "4222:4222"  # Client connections
      - "8222:8222"  # HTTP management
    command: |
      -js                 # Enable JetStream
      -sd /data          # Storage directory
      -m 8222            # Management port
    volumes:
      - ./nats-data:/data
```

**Start Local NATS**:
```bash
docker-compose up -d

# Verify
docker exec cim_local_nats nats server info
```

### Test Aggregates with Event Sourcing

Create test directory structure:
```bash
mkdir -p tests/{aggregates,events,state_machines,bdd}
```

Example aggregate test:
```rust
// tests/aggregates/application_tests.rs
#[cfg(test)]
mod tests {
    use async_nats;
    use cim_domain::EventStore;
    
    #[tokio::test]
    async fn test_application_lifecycle() {
        // Connect to local NATS
        let client = async_nats::connect("localhost:4222").await.unwrap();
        let jetstream = async_nats::jetstream::new(client);
        
        // Create event store
        let store = EventStore::new(jetstream, "APPLICATIONS").await.unwrap();
        
        // Create and test application aggregate
        let app_id = ApplicationId::new();
        let mut app = Application::new(app_id.clone());
        
        // Submit application
        let events = app.handle_command(ApplicationCommand::Submit {
            borrower: test_borrower(),
            amount: MoneyAmount::usd(350_000),
            property: test_property(),
        }).unwrap();
        
        // Persist and replay
        for event in events {
            store.append(&app_id, event).await.unwrap();
        }
        
        let loaded_events = store.load(&app_id).await.unwrap();
        let rebuilt = Application::from_events(loaded_events);
        
        assert_eq!(rebuilt.status, ApplicationStatus::Submitted);
    }
}
```

**SAGE Command**:
```bash
@sage Generate tests for Application aggregate
@sage Run all aggregate tests
```

### Validate State Machines

```rust
// tests/state_machines/underwriting_tests.rs
#[test]
fn test_underwriting_state_machine() {
    let mut machine = UnderwritingStateMachine::new();
    
    // Valid transitions
    assert!(machine.transition(State::Initial, Event::StartReview).is_ok());
    assert!(machine.transition(State::Reviewing, Event::Approve).is_ok());
    
    // Invalid transitions
    assert!(machine.transition(State::Initial, Event::Approve).is_err());
    assert!(machine.transition(State::Approved, Event::StartReview).is_err());
}
```

---

## Phase 5: When to Move to Infrastructure (Week 8+)

### Domain Readiness Checklist

```yaml
# readiness_checklist.yaml
domain_ready_for_infrastructure:
  conceptual_model:
    ✓ bounded_contexts_defined: true
    ✓ aggregates_identified: true
    ✓ events_catalogued: true
    ✓ state_machines_validated: true
    
  testing:
    ✓ unit_tests_passing: true
    ✓ integration_tests_passing: true
    ✓ event_sourcing_validated: true
    
  documentation:
    ✓ ubiquitous_language_documented: true
    ✓ context_maps_created: true
    
  team_alignment:
    ✓ domain_experts_reviewed: true
    ✓ developers_understand_model: true
    
  ready_for_infrastructure: true
```

### Transition to Infrastructure

When domain is stable, move to:
- [Infrastructure Setup Guide](06-infrastructure-setup.md)
- Or continue to [Step 7: Deployment](07-deployment.md)

---

## SAGE Commands Summary

```bash
# Observation Phase
@sage Observe API at [url] and document schema
@sage Observe database schema from [connection]
@sage Generate observation manifest

# Refinement Phase (n=6 iterations)
@sage Extract entities from observations (iteration 1)
@sage Identify relationships (iteration 2)
@sage Identify behaviors (iteration 3)
@sage Group into bounded contexts (iteration 4)
@sage Define boundaries (iteration 5)
@sage Validate completeness (iteration 6)

# Distillation Phase (T=3 levels)
@sage Extract bounded contexts (Strategic)
@sage Generate aggregates (Tactical)
@sage Create event catalog (Operational)

# Testing Phase
@sage Setup local NATS for testing
@sage Generate tests for [aggregate]
@sage Run all tests
@sage Validate state machines
```

---

## Complete Example: Mortgage Underwriting

See `/examples/mortgage-lending/` for complete walkthrough:
- Observation outputs (50+ external system observations)
- 6 refinement iterations documented
- Distilled DDD model (3 contexts, 8 aggregates, 24 events)
- Complete test suite
- Transition to infrastructure plan

---

## Next Steps

✅ You've completed Domain-First development
✅ You have a validated domain model
✅ You've tested with local NATS
✅ You're ready for infrastructure

**Next Step**: Choose your infrastructure path:
- [Infrastructure Setup](06-infrastructure-setup.md) - Deploy production infrastructure
- [Deployment](07-deployment.md) - Deploy to existing infrastructure

---

**Remember**: In Domain-First, we observe the universe before building our own world within it.
