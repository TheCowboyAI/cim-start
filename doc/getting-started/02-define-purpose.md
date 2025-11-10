# Step 2: Define Your Purpose

**Time Required**: ~15-30 minutes (thinking time included)

**Prerequisites**: [Step 1: Clone and Initialize](01-clone-and-initialize.md) ✅

---

## Overview

Before writing ANY code or deploying infrastructure, you must answer: **"Why does this CIM exist?"**

This aligns with **TRM Principle**: Clear problem definition (input x) before solution design (y, z).

Your purpose becomes:
- **Guide for observation** (Phase 1): What external systems to observe
- **Criteria for refinement** (Phase 2): What patterns to extract
- **Filter for distillation** (Phase 3): What DDD artifacts to create

---

## The Purpose File

Create `purpose.yaml` in your repository root using SAGE:

```bash
@sage Create purpose file for mortgage underwriting
```

**SAGE will guide you** through defining each section. You can also create it manually:

---

## Purpose.yaml Structure

```yaml
purpose:
  # Your CIM's name (matches repository name)
  name: "mortgage-underwriting"

  # Clear, concise description of what this CIM does
  description: |
    Automate mortgage underwriting decisions by observing loan applications,
    credit data, and property valuations, then distilling prototypical
    underwriting patterns for consistent, rapid decision-making.

  # What problem does this solve?
  problem_statement: |
    Manual underwriting is:
    - Slow: 5-7 days per application
    - Inconsistent: 20% variance between underwriters
    - Non-learning: Same mistakes repeated
    - High cost: $500-800 per underwriting decision

  # What does success look like?
  success_criteria:
    - metric: "Decision time"
      current: "5-7 days"
      target: "<24 hours"
      measurement: "Time from application submission to decision"

    - metric: "Consistency"
      current: "20% variance"
      target: "<5% variance"
      measurement: "Decision agreement rate between CIM and senior underwriters"

    - metric: "Throughput"
      current: "50 applications/month"
      target: "500+ applications/month"
      measurement: "Applications processed per month"

    - metric: "Learning"
      current: "None (static rules)"
      target: "Continuous improvement"
      measurement: "Monthly reduction in false positive/negative rates"

  # Domain boundaries - what's in and out of scope
  scope:
    in_scope:
      - "Loan application data validation"
      - "Credit risk assessment from bureau data"
      - "Property valuation analysis from appraisals"
      - "Automated underwriting decision recommendation"
      - "Risk scoring and classification"
      - "Decision explanation and audit trail"

    out_of_scope:
      - "Loan origination (separate system)"
      - "Loan servicing (separate system)"
      - "Payment processing (separate system)"
      - "Customer relationship management"
      - "Marketing and lead generation"
      - "Closing and title services"

  # Bounded context clarity
  bounded_contexts_anticipated:
    - name: "Application"
      responsibility: "Capture and validate loan application data"
      why: "Entry point for all underwriting decisions"

    - name: "Underwriting"
      responsibility: "Assess risk and generate decision recommendations"
      why: "Core decision-making logic"

    - name: "Risk-Assessment"
      responsibility: "Analyze credit, property, and financial risk factors"
      why: "Specialized risk calculations"

  # External systems to observe (never couple to!)
  external_systems:
    - name: "Experian Credit Bureau API"
      purpose: "Credit scores, credit history, trade lines"
      observation_method: "API responses (schema + examples)"
      observation_only: true
      coupling_forbidden: true
      reason: "We distill credit patterns, don't integrate with bureau"

    - name: "Property Valuation System (AVMs)"
      purpose: "Automated property valuations, comparables"
      observation_method: "API responses (schema + examples)"
      observation_only: true
      coupling_forbidden: true

    - name: "Legacy Underwriting Database"
      purpose: "Historical decisions for pattern learning"
      observation_method: "Database schema + sample queries"
      observation_only: true
      coupling_forbidden: true
      reason: "Learn from history, don't depend on legacy system"

    - name: "Document Processing System"
      purpose: "Extracted data from uploaded documents"
      observation_method: "JSON payloads + schemas"
      observation_only: true
      coupling_forbidden: true

  # Resources available for deployment
  resources:
    current_environment: "On-premises data center"

    available_hardware:
      - type: "Proxmox Cluster"
        nodes: 3
        specs: "Each: 128GB RAM, 32 cores, 2TB NVMe"
        location: "Primary data center"

    network:
      - vlan: "10.0.0.0/24 (Production)"
      - vlan: "172.16.0.0/24 (Storage/IPLD)"

    deployment_preference: "nixos-containers"  # or "vm" or "bare-metal"

  # People involved
  stakeholders:
    - role: "Product Owner"
      name: "Sarah Chen"
      email: "sarah.chen@acmelending.com"
      responsibility: "Business requirements and success criteria"

    - role: "Domain Expert"
      name: "Michael Torres"
      email: "michael.torres@acmelending.com"
      responsibility: "Underwriting expertise and pattern validation"

    - role: "System Administrator"
      name: "Alex Kumar"
      email: "alex.kumar@acmelending.com"
      responsibility: "Infrastructure deployment and operations"

  # Timeline expectations
  timeline:
    phase_1_observation: "2 weeks"
    phase_2_refinement: "3 weeks"
    phase_3_distillation: "2 weeks"
    phase_4_testing: "2 weeks"
    phase_5_deployment: "1 week"
    total_estimated: "10 weeks"

  # Compliance and regulatory considerations
  compliance:
    regulations:
      - "Fair Lending Act (non-discriminatory decisions)"
      - "ECOA (Equal Credit Opportunity Act)"
      - "FCRA (Fair Credit Reporting Act)"
      - "GDPR (if EU customers)"
      - "SOC 2 Type II (data security)"

    audit_requirements:
      - "All decisions must be explainable"
      - "Complete audit trail of data sources"
      - "No protected class information in decision logic"

  # Version and metadata
  version: "1.0.0"
  created: "2025-11-10"
  created_by: "SAGE + mortgage-underwriting team"
  last_updated: "2025-11-10"
```

---

## Key Sections Explained

### 1. Description
**One paragraph** that someone can read and understand what your CIM does.

💡 **Tip**: Use the format: "Automate [what] by observing [inputs], then distilling [outputs] for [benefit]."

### 2. Problem Statement
**Quantify the pain** you're solving. Use metrics:
- Time (how slow is current process?)
- Cost (how expensive?)
- Error rate (how inconsistent?)
- Scale (how limited?)

### 3. Success Criteria
**Measurable outcomes**. Each criterion needs:
- Current state (baseline)
- Target state (goal)
- Measurement method (how to verify)

### 4. Scope (Critical!)
**In-scope**: What this CIM WILL do
**Out-of-scope**: What this CIM will NOT do

🎯 **Purpose of scope**: Prevent scope creep and establish clear bounded context boundaries.

### 5. External Systems (Most Important!)
List ALL external systems you'll **observe** during prototypical space creation:

**For each system, specify**:
- What it does
- How you'll observe it (API schema, DB schema, documentation)
- **observation_only: true** (NEVER couple!)
- **coupling_forbidden: true** (enforce no dependencies)

This list becomes your Phase 1 observation targets.

### 6. Resources
Describe your deployment environment:
- Hardware available
- Network topology
- Deployment preferences

This determines infrastructure path in Step 5.

---

## SAGE-Guided Purpose Creation

Let SAGE help you:

```bash
# Interactive purpose creation:
@sage Create purpose file for mortgage underwriting

# SAGE will ask clarifying questions:
# - What problem are you solving?
# - Who are the stakeholders?
# - What external systems exist?
# - What are your success metrics?
# - What resources do you have?

# Review and refine:
@sage Review my purpose file for clarity and completeness

# Validate scope:
@sage Does my scope align with anticipated bounded contexts?

# Check external systems list:
@sage Have I identified all external systems to observe?
```

---

## Common Mistakes to Avoid

### ❌ Mistake 1: Vague Description
```yaml
# Bad:
description: "A system for processing loans"

# Good:
description: |
  Automate mortgage underwriting decisions by observing loan applications,
  credit data, and property valuations, then distilling prototypical
  underwriting patterns for consistent, rapid decision-making.
```

### ❌ Mistake 2: No Measurable Success Criteria
```yaml
# Bad:
success_criteria:
  - "Make underwriting faster"
  - "Improve consistency"

# Good:
success_criteria:
  - metric: "Decision time"
    current: "5-7 days"
    target: "<24 hours"
    measurement: "Time from application submission to decision"
```

### ❌ Mistake 3: Planning to Integrate with External Systems
```yaml
# Bad:
external_systems:
  - name: "Credit Bureau API"
    integration: "REST API client"  # ❌ NO!

# Good:
external_systems:
  - name: "Credit Bureau API"
    observation_method: "API schema + examples"
    observation_only: true
    coupling_forbidden: true  # ✅ YES!
```

### ❌ Mistake 4: Unclear Scope
```yaml
# Bad:
scope:
  in_scope:
    - "Loan processing"  # Too vague!

# Good:
scope:
  in_scope:
    - "Loan application data validation"
    - "Credit risk assessment from bureau data"
    - "Property valuation analysis"
  out_of_scope:
    - "Loan origination (separate system)"
    - "Loan servicing (separate system)"
```

---

## Validation Checklist

Before moving to Step 3, verify:

✅ **Clear one-paragraph description**
✅ **Quantified problem statement** (time, cost, error rate)
✅ **Measurable success criteria** (current → target)
✅ **Explicit in-scope and out-of-scope** boundaries
✅ **All external systems listed** with observation_only: true
✅ **Resources and deployment preferences** specified
✅ **Stakeholders identified** with roles and contact info
✅ **Compliance requirements** documented (if applicable)

---

## Why Purpose First?

**TRM Principle**: "Less is More"

- ✅ **Clarity**: Prevents building the wrong thing
- ✅ **Focus**: Limits observation to relevant external systems
- ✅ **Efficiency**: Guides refinement iterations (n=6)
- ✅ **Validation**: Provides success criteria for distillation
- ✅ **Communication**: Aligns team on shared understanding

**Your purpose.yaml becomes the input (x)** to TRM recursive reasoning:
- Observe → What to observe
- Refine → What patterns to extract
- Distill → What artifacts to create

---

## Example: Complete Purpose Files

See example purpose files in:
- [`/examples/mortgage-lending/purpose.yaml`](../examples/mortgage-lending/purpose.yaml)
- [`/examples/inventory-management/purpose.yaml`](../examples/inventory-management/purpose.yaml)
- [`/examples/customer-service/purpose.yaml`](../examples/customer-service/purpose.yaml)

---

## What's Next?

✅ You've created `purpose.yaml` with clear definition
✅ You've identified external systems to observe
✅ You've established measurable success criteria
✅ You've defined scope and bounded context boundaries

**Next Step**: [Step 3: Create Organization →](03-create-organization.md)

In Step 3, you'll create the Organization domain - who owns and operates this CIM.

---

## Quick Commands

```bash
# Create purpose file:
@sage Create purpose file for [your domain]

# Review purpose:
@sage Review my purpose file

# Validate scope:
@sage Check if my scope aligns with bounded contexts

# List external systems:
@sage What external systems should I observe for [your domain]?
```

---

**Ready for Step 3?** → [Create Organization](03-create-organization.md)
