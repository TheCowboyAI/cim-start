# CIM Domain Quick Start Guide

Copyright 2025 - Cowboy AI, LLC

## 🚀 The SAGE-Powered Quick Start

**NEW: Let SAGE and 25 expert agents guide you through domain creation!**

Instead of filling out templates manually, simply ask SAGE to orchestrate your domain creation:

```bash
# After cloning CIM-Start and running 'claude init':
@sage Create a complete CIM domain for my [business area]
```

SAGE will coordinate all 25 expert agents to:
- Conduct event storming sessions
- Design your domain boundaries
- Create mathematical foundations
- Set up infrastructure
- Generate all necessary code and configuration

## 📋 Manual 15-Minute Domain Template

(Or if you prefer the manual approach, fill in this template to create your domain in 15 minutes)

## Step 1: Name Your Domain

**What business area are you modeling?**
```yaml
domain_name: # e.g., "mortgage-lending", "inventory-management", "customer-support"
description: # One sentence describing what this domain does
```

## Step 2: Identify Key Events (5-10 events)

**What happens in your business? (Use past tense)**

Fill in at least 5 events:
```yaml
events:
  - name: # e.g., "ApplicationSubmitted"
    description: # What happened?
    triggered_by: # Who/what caused this?
    
  - name: # e.g., "ApplicationApproved" 
    description: #
    triggered_by: #
    
  - name: # 
    description: #
    triggered_by: #
    
  - name: #
    description: #
    triggered_by: #
    
  - name: #
    description: #
    triggered_by: #
```

## Step 3: Define Main Entities (Aggregates)

**What are the main "things" in your domain?**

Fill in 2-4 main entities:
```yaml
aggregates:
  - name: # e.g., "LoanApplication"
    description: # What is this?
    key_properties:
      - # e.g., "applicationId"
      - # e.g., "borrowerName"
      - # e.g., "loanAmount"
    
  - name: # 
    description: #
    key_properties:
      - #
      - #
      - #
```

## Step 4: Map Commands to Events

**What actions do users take?**

For each user action, what event(s) result?
```yaml
commands:
  - command: # e.g., "SubmitApplication"
    produces_events: 
      - # e.g., "ApplicationSubmitted"
      - # (optional additional event)
    
  - command: #
    produces_events:
      - #
    
  - command: #
    produces_events:
      - #
```

## Step 5: Define Business Rules (Policies)

**What happens automatically?**

When X happens, then Y should happen:
```yaml
policies:
  - when: # e.g., "ApplicationSubmitted"
    then: # e.g., "Start credit check"
    
  - when: #
    then: #
    
  - when: #
    then: #
```

## Step 6: Sketch Your Workflow

**Draw your main business flow:**

Fill in the steps:
```
Start → [________] → [________] → [________] → End
         ↓              ↓              ↓
    [What happens] [What happens] [What happens]
```

## Step 7: List External Systems

**What other systems/domains do you need?**
```yaml
dependencies:
  - system: # e.g., "credit-bureau"
    for: # e.g., "credit checks"
    
  - system: #
    for: #
```

## 🎉 Congratulations!

You've defined your domain! Now you can:

1. Save this as `domains/your-domain/domain-definition.yaml`
2. Run validation: `./scripts/validate-domain.sh your-domain`
3. Generate code: Ask Claude to help implement your aggregates
4. Start building: Use the CIM modules to assemble your solution

## Example: Completed Template

```yaml
domain_name: private-mortgage-lending
description: Manages private mortgage loan origination and servicing

events:
  - name: ApplicationSubmitted
    description: Borrower submitted a loan application
    triggered_by: Borrower via web form
    
  - name: CreditCheckCompleted
    description: Credit bureau returned credit report
    triggered_by: Credit check system
    
  - name: UnderwritingDecisionMade
    description: Underwriter approved or denied the loan
    triggered_by: Underwriter
    
  - name: LoanOriginated
    description: Loan was funded and created
    triggered_by: Funding system
    
  - name: PaymentReceived
    description: Monthly payment was received
    triggered_by: Payment processor

aggregates:
  - name: LoanApplication
    description: Loan application and approval process
    key_properties:
      - applicationId
      - borrowerId
      - propertyAddress
      - requestedAmount
      - applicationStatus
    
  - name: Loan
    description: Active loan being serviced
    key_properties:
      - loanId
      - currentBalance
      - interestRate
      - paymentSchedule

commands:
  - command: SubmitApplication
    produces_events: 
      - ApplicationSubmitted
      - CreditCheckRequested
    
  - command: MakePayment
    produces_events:
      - PaymentReceived
      - BalanceUpdated

policies:
  - when: ApplicationSubmitted
    then: Initiate credit check
    
  - when: CreditCheckCompleted
    then: Route to underwriting queue
    
  - when: PaymentReceived
    then: Apply to principal and interest

workflow: |
  Start → Application → Credit Check → Underwriting → Funding → Servicing
           ↓              ↓               ↓            ↓          ↓
      [Validated]    [Score>650]    [Approved]    [Funded]  [Monthly]

dependencies:
  - system: credit-bureau
    for: credit checks
  - system: property-valuation
    for: appraisals
  - system: payment-processor
    for: ACH transfers
```

## Need Help?

**Recommended: Use SAGE for Complete Orchestration**
```bash
@sage Help me create a complete [business type] domain
@sage Guide me through event storming for [industry]
@sage Set up all infrastructure for my domain
```

**Or Ask Specific Experts Directly:**
- `@event-storming-expert` - "Help me identify events for my [business type] domain"
- `@ddd-expert` - "What aggregates make sense for [industry]?"
- `@domain-expert` - "Generate the cim-graph structure for my domain"
- `@tdd-expert` - "Create test-driven command handlers for my aggregates"
- `@conceptual-spaces-expert` - "Design semantic spaces for my domain concepts"
- `@graph-expert` - "Model relationships in my domain as a graph"

**SAGE Coordinates All 25 Experts Including:**
- Domain & Architecture (6 experts)
- Development & Testing (3 experts)
- Infrastructure (5 experts)
- UI/UX (4 experts)
- Knowledge & Semantics (3 experts)
- Organization & Context (3 experts)
- Master Orchestration (SAGE)