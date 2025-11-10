# Step 3: Create Organization

**Time Required**: ~10-15 minutes

**Prerequisites**:
- [Step 1: Clone and Initialize](01-clone-and-initialize.md) ✅
- [Step 2: Define Purpose](02-define-purpose.md) ✅

---

## Overview

Every CIM is owned and operated by an **Organization**. This could be:
- A company (ACME Lending Corp)
- A department (IT Department)
- A project team (Underwriting Automation Team)
- A unit within an organization (Retail Banking Unit)

The Organization domain is **foundational** - it establishes WHO owns this CIM and what organizational context it operates in.

---

## Why Organization Matters

**From your purpose.yaml**, you defined stakeholders like:
```yaml
stakeholders:
  - name: "Sarah Chen"
    email: "sarah.chen@acmelending.com"  # ← @acmelending.com
```

That email domain tells us: **This CIM belongs to ACME Lending**.

The Organization domain captures:
- Official organizational identity
- Hierarchical structure (if applicable)
- Contact information
- Regulatory/compliance context
- Resource ownership

---

## Create Organization Domain

### Option 1: SAGE-Guided Creation (Recommended)

```bash
@sage Create organization domain for ACME Lending
```

**SAGE will**:
1. Create `domains/organization/` directory structure
2. Generate organization domain YAML files
3. Set up organization aggregate
4. Create initial organization events

### Option 2: Manual Creation

Create the organization domain structure:

```bash
mkdir -p domains/organization
cd domains/organization
```

---

## Organization Domain Structure

```
domains/organization/
├── domain.yaml                  # Organization domain definition
├── organization.yaml            # Organization aggregate data
├── departments.yaml             # Department structure (if applicable)
├── policies.yaml                # Organizational policies
└── README.md                    # Organization domain documentation
```

---

## domain.yaml - Organization Domain Definition

```yaml
domain:
  name: "organization"
  version: "1.0.0"
  purpose: "Define organizational identity, structure, and policies"

  # This domain is used by ALL other domains
  foundational: true

  aggregates:
    - name: "Organization"
      root_entity: "OrganizationId"
      description: "Top-level organizational entity"

    - name: "Department"
      root_entity: "DepartmentId"
      description: "Organizational unit or division"

  value_objects:
    - "OrganizationName"
    - "TaxId"
    - "Address"
    - "ContactInfo"
    - "DepartmentName"

  events:
    - "OrganizationCreated"
    - "OrganizationUpdated"
    - "DepartmentCreated"
    - "DepartmentRestructured"

  # Domain boundaries
  responsibilities:
    - "Maintain official organizational identity"
    - "Track organizational structure and hierarchy"
    - "Define organizational policies"
    - "Manage compliance and regulatory context"

  not_responsible_for:
    - "Employee management (that's People domain)"
    - "Resource allocation (that's Resource domain)"
    - "Location management (that's Location domain)"
```

---

## organization.yaml - Organization Aggregate Data

```yaml
organization:
  # Unique identifier (UUID v7)
  id: "01JCRF9G4QM8NZPXWVYT5KC7ST"

  # Official organization information
  legal_name: "ACME Lending Corporation"
  doing_business_as: "ACME Lending"
  short_name: "ACME"

  # Legal identifiers
  tax_id: "12-3456789"  # EIN or equivalent
  registration:
    jurisdiction: "Delaware, USA"
    registration_number: "5432891"
    registration_date: "2015-03-15"

  # Organization type
  type: "Corporation"  # Corporation, LLC, Partnership, Non-profit, etc.
  industry: "Financial Services"
  sub_industry: "Mortgage Lending"

  # Contact information
  headquarters:
    street: "123 Financial Plaza"
    city: "New York"
    state: "NY"
    postal_code: "10004"
    country: "USA"

  contact:
    phone: "+1-555-LENDING"
    email: "info@acmelending.com"
    website: "https://acmelending.com"

  # Organizational structure
  structure:
    type: "hierarchical"  # hierarchical, flat, matrix, network

    departments:
      - id: "01JCRF9G4QM8NZPXWVYT5KC7SU"
        name: "Technology"
        parent: null  # Top-level department

      - id: "01JCRF9G4QM8NZPXWVYT5KC7SV"
        name: "Underwriting Operations"
        parent: null

      - id: "01JCRF9G4QM8NZPXWVYT5KC7SW"
        name: "Underwriting Automation"
        parent: "01JCRF9G4QM8NZPXWVYT5KC7SV"  # Under Underwriting Operations

  # Compliance and regulatory
  compliance:
    licenses:
      - type: "NMLS"
        number: "123456"
        jurisdiction: "Nationwide"
        expiration: "2026-12-31"

    certifications:
      - "SOC 2 Type II"
      - "ISO 27001"

    regulations:
      - "Fair Lending Act"
      - "ECOA (Equal Credit Opportunity Act)"
      - "FCRA (Fair Credit Reporting Act)"
      - "GDPR (EU customers)"

  # CIM ownership
  cims_owned:
    - name: "mortgage-underwriting"
      purpose: "Automated mortgage underwriting decisions"
      responsible_department: "01JCRF9G4QM8NZPXWVYT5KC7SW"
      primary_contact: "sarah.chen@acmelending.com"
      deployed: false
      deployment_target: "2025-12-15"

  # Metadata
  version: "1.0.0"
  created: "2025-11-10"
  created_by: "SAGE"
  last_updated: "2025-11-10"
```

---

## departments.yaml - Department Structure (Optional)

If your organization has complex structure:

```yaml
departments:
  - id: "01JCRF9G4QM8NZPXWVYT5KC7SU"
    name: "Technology"
    code: "TECH"
    type: "Core Function"
    parent: null

    responsibilities:
      - "Infrastructure management"
      - "Software development"
      - "CIM development and deployment"

    head:
      name: "Alex Kumar"
      email: "alex.kumar@acmelending.com"
      title: "CTO"

  - id: "01JCRF9G4QM8NZPXWVYT5KC7SV"
    name: "Underwriting Operations"
    code: "UW-OPS"
    type: "Business Unit"
    parent: null

    responsibilities:
      - "Mortgage underwriting"
      - "Risk assessment"
      - "Decision approval"

    head:
      name: "Michael Torres"
      email: "michael.torres@acmelending.com"
      title: "VP of Underwriting"

  - id: "01JCRF9G4QM8NZPXWVYT5KC7SW"
    name: "Underwriting Automation"
    code: "UW-AUTO"
    type: "Project Team"
    parent: "01JCRF9G4QM8NZPXWVYT5KC7SV"

    responsibilities:
      - "CIM development for underwriting"
      - "Process automation"
      - "Pattern recognition"

    head:
      name: "Sarah Chen"
      email: "sarah.chen@acmelending.com"
      title: "Product Owner - Underwriting CIM"
```

---

## policies.yaml - Organizational Policies (Optional)

```yaml
policies:
  data_governance:
    classification:
      - level: "Public"
        description: "Can be shared externally"
        examples: ["Marketing materials", "Public website content"]

      - level: "Internal"
        description: "For employees only"
        examples: ["Internal processes", "Training materials"]

      - level: "Confidential"
        description: "Restricted access"
        examples: ["Customer PII", "Credit data", "Financial records"]

      - level: "Restricted"
        description: "Highest security"
        examples: ["Encryption keys", "Audit logs", "Compliance reports"]

    retention:
      customer_data: "7 years (regulatory requirement)"
      audit_logs: "7 years (SOC 2 requirement)"
      application_data: "10 years (FCRA requirement)"

  security:
    authentication:
      - "Multi-factor authentication required"
      - "Password rotation every 90 days"
      - "Biometric authentication for production access"

    encryption:
      - "TLS 1.3 for all network traffic"
      - "AES-256 for data at rest"
      - "Key rotation every 90 days"

  compliance:
    fair_lending:
      - "No protected class information in decision logic"
      - "All decisions must be auditable and explainable"
      - "Regular testing for disparate impact"

    data_privacy:
      - "GDPR compliance for EU customers"
      - "Right to be forgotten implemented"
      - "Data minimization principle applied"
```

---

## SAGE Commands for Organization Domain

```bash
# Create organization domain:
@sage Create organization domain for ACME Lending

# Add department structure:
@sage Add department: Technology, reporting to CEO
@sage Add department: Underwriting Automation, reporting to Underwriting Operations

# Define organizational policies:
@sage What policies should I define for a mortgage lending organization?

# Validate organization domain:
@sage Review my organization domain for completeness

# Link to purpose:
@sage Connect my organization domain to purpose.yaml stakeholders
```

---

## Validation Checklist

Before moving to Step 4, verify:

✅ **Organization domain created** in `domains/organization/`
✅ **Legal name and identifiers** specified (tax ID, registration)
✅ **Contact information** complete (address, phone, email, website)
✅ **Department structure** defined (if applicable)
✅ **Compliance and licenses** documented (if regulated industry)
✅ **CIM ownership** established (this CIM belongs to this org)
✅ **Stakeholders from purpose.yaml** mapped to departments

---

## Why Organization Domain Matters

1. **Identity**: Establishes WHO owns and operates this CIM
2. **Context**: Provides organizational context for all decisions
3. **Compliance**: Documents regulatory and compliance requirements
4. **Governance**: Defines policies that apply to this CIM
5. **Ownership**: Makes clear who is responsible for this CIM

**From DDD perspective**: Organization is a **Foundational Domain** - it's used by all other domains but doesn't depend on them.

---

## Connection to Next Steps

Your Organization domain will be referenced by:
- **People domain** (Step 4): People work for departments in this organization
- **Domain models** (Step 6): Your main domain operates within this organizational context
- **Infrastructure** (Step 7): Deployed using this organization's resources
- **Security** (cim-keys): PKI tied to this organization's identity

---

## Examples

See complete organization domains in:
- [`/examples/mortgage-lending/domains/organization/`](../examples/mortgage-lending/domains/organization/)
- [`/examples/inventory-management/domains/organization/`](../examples/inventory-management/domains/organization/)

---

## What's Next?

✅ You've created the Organization domain
✅ You've documented organizational identity and structure
✅ You've established compliance and policy context
✅ You've connected stakeholders to organizational units

**Next Step**: [Step 4: Add People →](04-add-people.md)

In Step 4, you'll create the People domain - who will administer and use this CIM.

---

## Quick Commands

```bash
# Create organization:
@sage Create organization domain for [org name]

# Add departments:
@sage Add department: [name], reporting to [parent]

# Define policies:
@sage Create organizational policies for [industry]

# Validate:
@sage Review organization domain completeness
```

---

**Ready for Step 4?** → [Add People](04-add-people.md)
