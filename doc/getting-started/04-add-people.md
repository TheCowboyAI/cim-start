# Step 4: Add People

**Time Required**: ~15-20 minutes

**Prerequisites**:
- [Step 1: Clone and Initialize](01-clone-and-initialize.md) ✅
- [Step 2: Define Purpose](02-define-purpose.md) ✅
- [Step 3: Create Organization](03-create-organization.md) ✅

---

## Overview

Every CIM is built, administered, and used by **People**. The People domain is **foundational** - it establishes WHO will interact with your CIM.

In Step 3, you defined your organization. In this step, you'll add the people who work for that organization and will use/manage this CIM.

---

## Why People Matter

**From your purpose.yaml** (Step 2), you defined stakeholders:
```yaml
stakeholders:
  - role: "Product Owner"
    name: "Sarah Chen"
    email: "sarah.chen@acmelending.com"

  - role: "Domain Expert"
    name: "Michael Torres"
    email: "michael.torres@acmelending.com"
```

These people need to be formally added to your CIM so they can:
- Authenticate and access the system
- Be assigned roles and permissions
- Own resources and artifacts
- Appear in audit trails ("created_by", "modified_by")
- Form teams for collaborative work

---

## Create People Domain

### Option 1: SAGE-Guided Creation (Recommended)

```bash
@sage Create people domain with stakeholders from my purpose.yaml
```

**SAGE will**:
1. Read your purpose.yaml stakeholders
2. Create `domains/people/` directory structure
3. Generate person instances for each stakeholder
4. Set up roles and permissions
5. Create initial team structures

### Option 2: Manual Creation

Create the people domain structure:

```bash
mkdir -p domains/people/{aggregates,value-objects,events,commands,projections,instances}
cd domains/people
```

---

## People Domain Structure

```
domains/people/
├── domain.yaml                  # People domain definition
├── aggregates/
│   ├── person.yaml             # Person aggregate schema
│   ├── team.yaml               # Team aggregate schema
│   └── role.yaml               # Role aggregate schema
├── value-objects/
│   ├── person-name.yaml        # Name structure
│   ├── contact-info.yaml       # Email, phone, addresses
│   └── skills.yaml             # Professional skills
├── events/
│   ├── person-events.yaml      # Person lifecycle events
│   ├── team-events.yaml        # Team events
│   └── role-events.yaml        # Role assignment events
├── instances/                   # Actual people in your system
│   ├── sarah-chen.yaml
│   ├── michael-torres.yaml
│   └── alex-kumar.yaml
└── README.md                    # People domain documentation
```

---

## domain.yaml - People Domain Definition

```yaml
# domains/people/domain.yaml
domain:
  name: "people"
  version: "1.0.0"
  purpose: "Define people, roles, teams, and permissions"

  # Foundational domain used by all others
  foundational: true

  aggregates:
    - name: "Person"
      root_entity: "PersonId"
      description: "Individual who interacts with the CIM system"

    - name: "Team"
      root_entity: "TeamId"
      description: "Group of people working together"

    - name: "Role"
      root_entity: "RoleId"
      description: "Named set of permissions and responsibilities"

  value_objects:
    - "PersonName"
    - "Email"
    - "Skill"
    - "PhoneNumber"
    - "Address"

  events:
    - "PersonAdded"
    - "PersonUpdated"
    - "RoleAssigned"
    - "RoleRevoked"
    - "TeamFormed"
    - "TeamMemberAdded"

  # Domain boundaries
  responsibilities:
    - "Maintain person identity and authentication"
    - "Track roles and permissions"
    - "Manage team structures"
    - "Provide audit trail for all actions"

  not_responsible_for:
    - "Payroll or HR functions"
    - "Performance reviews"
    - "Time tracking"
    - "Resource allocation (separate domain)"
```

---

## Adding People from purpose.yaml

### Person Instance Template

```yaml
# domains/people/instances/sarah-chen.yaml
person:
  # Unique identifier (UUID v7 - time-ordered)
  id: "person_01JCRFHK8QM8NZPXWVYT5KC7ST"

  # Core identity
  core_identity:
    legal_name:
      given_name: "Sarah"
      family_name: "Chen"
      preferred_name: "Sarah"

  # Contact information
  contact:
    primary_email: "sarah.chen@acmelending.com"
    phones:
      - number: "+1-555-0101"
        type: "mobile"

  # Link to Organization from Step 3
  organization:
    org_id: "org_01JCRF9G4QM8NZPXWVYT5KC7ST"  # From Step 3
    department: "Underwriting Automation"
    title: "Product Owner - Underwriting CIM"
    start_date: "2024-01-15"

  # Roles assigned
  roles:
    assigned_roles:
      - role_id: "role_product_owner"
        valid_from: "2024-01-15"

      - role_id: "role_cim_administrator"
        valid_from: "2024-01-15"

  # Professional skills
  professional:
    title: "Product Owner"
    skills:
      - category: "Domain"
        name: "Mortgage Underwriting"
        proficiency: "Expert"
        years_experience: 8.0

      - category: "Leadership"
        name: "Product Management"
        proficiency: "Advanced"
        years_experience: 5.0

  # Authentication
  authentication:
    username: "schen"
    password_hash: "$2b$12$..."  # Bcrypt hash (generated)
    mfa_enabled: true

  # Metadata
  metadata:
    created_at: "2025-11-10T10:00:00Z"
    created_by: "system"  # Bootstrap user
    version: 1

  # Current state
  state: "Active"
```

### Complete Example: Domain Expert

```yaml
# domains/people/instances/michael-torres.yaml
person:
  id: "person_01JCRFHK8QM8NZPXWVYT5KC7SU"

  core_identity:
    legal_name:
      given_name: "Michael"
      family_name: "Torres"
      preferred_name: "Mike"

  contact:
    primary_email: "michael.torres@acmelending.com"
    phones:
      - number: "+1-555-0102"
        type: "work"

  organization:
    org_id: "org_01JCRF9G4QM8NZPXWVYT5KC7ST"
    department: "Underwriting Operations"
    title: "VP of Underwriting"
    start_date: "2015-03-20"

  roles:
    assigned_roles:
      - role_id: "role_domain_expert"
        valid_from: "2024-01-15"

      - role_id: "role_underwriting_approver"
        valid_from: "2015-03-20"

  professional:
    title: "VP of Underwriting"
    skills:
      - category: "Domain"
        name: "Mortgage Underwriting"
        proficiency: "Expert"
        years_experience: 15.0

      - category: "Domain"
        name: "Risk Assessment"
        proficiency: "Expert"
        years_experience: 15.0

      - category: "Domain"
        name: "Regulatory Compliance"
        proficiency: "Advanced"
        years_experience: 10.0

  authentication:
    username: "mtorres"
    password_hash: "$2b$12$..."
    mfa_enabled: true

  metadata:
    created_at: "2025-11-10T10:05:00Z"
    created_by: "person_01JCRFHK8QM8NZPXWVYT5KC7ST"
    version: 1

  state: "Active"
```

### System Administrator

```yaml
# domains/people/instances/alex-kumar.yaml
person:
  id: "person_01JCRFHK8QM8NZPXWVYT5KC7SV"

  core_identity:
    legal_name:
      given_name: "Alex"
      family_name: "Kumar"

  contact:
    primary_email: "alex.kumar@acmelending.com"
    phones:
      - number: "+1-555-0103"
        type: "mobile"

  organization:
    org_id: "org_01JCRF9G4QM8NZPXWVYT5KC7ST"
    department: "Technology"
    title: "CTO"
    start_date: "2018-06-01"

  roles:
    assigned_roles:
      - role_id: "role_system_administrator"
        valid_from: "2024-01-15"

      - role_id: "role_infrastructure_engineer"
        valid_from: "2024-01-15"

  professional:
    title: "CTO"
    skills:
      - category: "Technical"
        name: "NixOS Administration"
        proficiency: "Expert"
        years_experience: 6.0

      - category: "Technical"
        name: "NATS Infrastructure"
        proficiency: "Advanced"
        years_experience: 3.0

      - category: "Technical"
        name: "Network Security"
        proficiency: "Advanced"
        years_experience: 8.0

  authentication:
    username: "akumar"
    password_hash: "$2b$12$..."
    mfa_enabled: true

  metadata:
    created_at: "2025-11-10T10:10:00Z"
    created_by: "person_01JCRFHK8QM8NZPXWVYT5KC7ST"
    version: 1

  state: "Active"
```

---

## Defining Roles

Create role definitions for your CIM:

```yaml
# domains/people/instances/roles.yaml
roles:
  - id: "role_cim_administrator"
    name: "CIM Administrator"
    code: "CIM_ADMIN"
    description: "Full administrative access to CIM system"

    permissions:
      - "person.create"
      - "person.update"
      - "person.delete"
      - "role.assign"
      - "role.revoke"
      - "team.create"
      - "team.manage"
      - "domain.configure"
      - "infrastructure.manage"

    organization:
      org_id: "org_01JCRF9G4QM8NZPXWVYT5KC7ST"
      scope: "Global"

  - id: "role_product_owner"
    name: "Product Owner"
    code: "PO"
    description: "Owns product backlog and requirements"

    permissions:
      - "requirements.define"
      - "requirements.approve"
      - "backlog.manage"
      - "release.plan"

    organization:
      org_id: "org_01JCRF9G4QM8NZPXWVYT5KC7ST"
      scope: "Project"

  - id: "role_domain_expert"
    name: "Domain Expert"
    code: "EXPERT"
    description: "Subject matter expertise for domain modeling"

    permissions:
      - "domain.model.validate"
      - "requirements.clarify"
      - "patterns.identify"

    organization:
      org_id: "org_01JCRF9G4QM8NZPXWVYT5KC7ST"
      scope: "Domain"

  - id: "role_system_administrator"
    name: "System Administrator"
    code: "SYSADMIN"
    description: "Infrastructure and system administration"

    permissions:
      - "infrastructure.deploy"
      - "infrastructure.configure"
      - "nats.admin"
      - "security.manage"
      - "monitoring.configure"

    organization:
      org_id: "org_01JCRF9G4QM8NZPXWVYT5KC7ST"
      scope: "Global"

  - id: "role_developer"
    name: "Developer"
    code: "DEV"
    description: "Software development access"

    permissions:
      - "code.read"
      - "code.write"
      - "test.execute"
      - "deploy.dev_environment"

    organization:
      org_id: "org_01JCRF9G4QM8NZPXWVYT5KC7ST"
      scope: "Project"
```

---

## Creating Teams (Optional)

If your organization has team structures:

```yaml
# domains/people/instances/core-team.yaml
team:
  id: "team_01JCRFHK8QM8NZPXWVYT5KC7XY"

  identity:
    name: "Underwriting CIM Team"
    code: "UW-CIM"
    description: "Team building the mortgage underwriting CIM"

  organization:
    org_id: "org_01JCRF9G4QM8NZPXWVYT5KC7ST"
    department: "Underwriting Automation"

  membership:
    lead: "person_01JCRFHK8QM8NZPXWVYT5KC7ST"  # Sarah Chen

    members:
      - person_id: "person_01JCRFHK8QM8NZPXWVYT5KC7ST"
        role_in_team: "Product Owner"
        joined_at: "2024-01-15"

      - person_id: "person_01JCRFHK8QM8NZPXWVYT5KC7SU"
        role_in_team: "Domain Expert"
        joined_at: "2024-01-15"

      - person_id: "person_01JCRFHK8QM8NZPXWVYT5KC7SV"
        role_in_team: "Infrastructure Lead"
        joined_at: "2024-01-15"

  characteristics:
    team_type: "Project"
    formation_date: "2024-01-15"

    goals:
      - "Automate mortgage underwriting decisions"
      - "Reduce underwriting time to <24 hours"
      - "Achieve <5% decision variance"
      - "Deploy production CIM by 2025-12-15"

  metadata:
    created_at: "2025-11-10T10:15:00Z"
    created_by: "person_01JCRFHK8QM8NZPXWVYT5KC7ST"
    version: 1

  state: "Active"
```

---

## SAGE Commands for People Domain

```bash
# Create people domain from purpose.yaml stakeholders:
@sage Create people domain with my stakeholders

# Add a person manually:
@sage Add person: John Doe, email: john.doe@example.com, role: Developer

# Define roles:
@sage Create standard roles for a CIM project

# Create a team:
@sage Create team: Core Platform, lead: Sarah Chen

# Assign role to person:
@sage Assign role 'CIM Administrator' to Sarah Chen

# Review people domain:
@sage Show me all people in my CIM
```

---

## Integration with Organization Domain

People domain references Organization domain through:

```yaml
# In person instance:
organization:
  org_id: "org_01JCRF9G4QM8NZPXWVYT5KC7ST"  # ← From Step 3
  department: "Underwriting Automation"      # ← From org structure
  title: "Product Owner"
  start_date: "2024-01-15"
```

This creates a strong link:
- **Person** works for **Organization**
- **Person** is in **Department** (from Organization structure)
- **Person** has **Role** scoped to **Organization**

---

## Why DDD Patterns Matter

The People domain uses **Domain-Driven Design** patterns:

### Aggregates
- **Person**: Root entity with PersonId
- **Team**: Root entity with TeamId
- **Role**: Root entity with RoleId

### Value Objects
- **PersonName**: Immutable, structural equality
- **Email**: Validated format
- **Skill**: Professional competency

### Events
- **PersonAdded**: New person in system
- **RoleAssigned**: Role granted to person
- **TeamFormed**: New team created

### Phantom-Typed IDs
```rust
// Compile-time safety - can't mix person ID with team ID
pub struct PersonId(Uuid);  // PersonMarker phantom type
pub struct TeamId(Uuid);    // TeamMarker phantom type

// This won't compile:
let person_id: PersonId = get_person();
let team_id: TeamId = person_id;  // ❌ Type mismatch!
```

---

## Reference Implementation

**Production-ready People domain** exists at:
- `/git/thecowboyai/cim-domain-person`
- 194 tests passing
- Full event sourcing
- NATS JetStream integration
- Phantom-typed IDs
- Pure functional updates

You can reference this implementation for:
- Complete aggregate designs
- Event sourcing patterns
- Testing strategies
- NATS integration

---

## Validation Checklist

Before moving to Step 5, verify:

✅ **People domain created** in `domains/people/`
✅ **Stakeholders from purpose.yaml** added as person instances
✅ **Roles defined** for your CIM (admin, product owner, domain expert, etc.)
✅ **Person instances reference Organization** from Step 3
✅ **Teams created** (if your org has team structure)
✅ **Authentication credentials** set for each person
✅ **Skills and professional info** documented

---

## Connection to Next Steps

Your People domain will be used by:
- **Authentication/Authorization**: Who can access the CIM
- **Audit Trails**: "created_by", "modified_by" in all events
- **Ownership**: Resources owned by people or teams
- **Collaboration**: Teams working on domain models
- **Responsibility**: Who is accountable for what

**From Event Sourcing perspective**: Every domain event will include:
```yaml
SomeEventOccurred:
  event_id: EventId
  aggregate_id: AggregateId
  occurred_by: PersonId  # ← From People domain!
  occurred_at: DateTime
  # ... event data
```

---

## What's Next?

✅ You've created the People domain
✅ You've added stakeholders from your purpose
✅ You've defined roles and permissions
✅ You've established teams (if applicable)

**Next Step**: [Step 5: Choose Your Path →](05-choose-your-path.md)

In Step 5, you'll make a critical decision:
- **Path A: Domain-First** → Build domain models first, infrastructure later
- **Path B: Infrastructure-First** → Deploy infrastructure first, build domain on production

---

## Quick Commands

```bash
# Create people domain:
@sage Create people domain from purpose.yaml

# Add person:
@sage Add person: [name], email: [email], role: [role]

# Create team:
@sage Create team: [name], lead: [person]

# Assign role:
@sage Assign role '[role]' to [person]

# Review:
@sage Show all people in my CIM
```

---

**Ready for Step 5?** → [Choose Your Path](05-choose-your-path.md)
