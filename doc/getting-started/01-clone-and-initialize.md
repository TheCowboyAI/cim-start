# Step 1: Clone and Initialize

**Time Required**: ~5 minutes

---

## Overview

CIM-Start is a **template repository**. When you clone it with YOUR domain name, that cloned repository becomes your actual CIM project.

**Key Insight**: The repository name you choose becomes your CIM's domain name.

---

## Prerequisites

Before starting, ensure you have:

- ✅ **Git** installed
- ✅ **Claude Code** installed (`npm install -g @anthropic/claude`)
- ✅ **Nix** installed (optional but recommended) - [nix.dev](https://nix.dev)
- ✅ **A clear idea** of what your CIM will do (we'll formalize this in Step 2)

---

## Step 1.1: Clone with Your Domain Name

Choose a descriptive name that represents your CIM's purpose:

```bash
# ✅ Good domain names (clear, specific):
git clone https://github.com/TheCowboyAI/cim-start.git mortgage-underwriting
git clone https://github.com/TheCowboyAI/cim-start.git inventory-management
git clone https://github.com/TheCowboyAI/cim-start.git customer-support

# ❌ Avoid vague names:
git clone https://github.com/TheCowboyAI/cim-start.git my-project
git clone https://github.com/TheCowboyAI/cim-start.git test
git clone https://github.com/TheCowboyAI/cim-start.git cim-1
```

**Example**: Let's create a mortgage underwriting CIM:

```bash
git clone https://github.com/TheCowboyAI/cim-start.git mortgage-underwriting
cd mortgage-underwriting
```

---

## Step 1.2: Initialize Claude Code

Initialize Claude Code in your new repository:

```bash
# Inside your cloned repository:
claude init

# Claude Code will:
# - Detect the repository name ("mortgage-underwriting")
# - Load SAGE (master orchestrator)
# - Activate 26 specialized expert agents
# - Prepare the development environment
```

**What just happened?**

1. Claude Code detected your repo name: `mortgage-underwriting`
2. SAGE transformed from "template mode" to "active CIM orchestrator"
3. All 26 expert agents are now available to guide you
4. The template is now YOUR project, not a template anymore

---

## Step 1.3: Verify SAGE is Active

Test that SAGE is working:

```bash
# In Claude Code CLI or in your editor:
@sage Hello, I just cloned cim-start as mortgage-underwriting
```

**Expected Response**:
```
SAGE: Welcome to your mortgage-underwriting CIM project!

I've detected that you're building a CIM for mortgage underwriting.
I'll coordinate our 26 expert agents to guide you through:

1. Defining your CIM's purpose
2. Creating your organization domain
3. Adding people to your system
4. Choosing between Domain-First or Infrastructure-First development
5. Building your domain model with prototypical space creation
6. Deploying your CIM

Let's start with Step 2: Defining your purpose.
Would you like me to create a purpose.yaml template for mortgage underwriting?
```

---

## Step 1.4: Understand What You Have

Your cloned repository contains:

```
mortgage-underwriting/           # ← Your CIM project (no longer a template!)
├── README.md                    # Project overview (customize this)
├── CLAUDE.md                    # Agent guidance
├── SAGE.md                      # SAGE orchestration overview
├── purpose.yaml                 # ← You'll create this in Step 2
├── flake.nix                    # Nix development environment
├── docker-compose.yml           # Local NATS infrastructure
│
├── .claude/                     # Claude Code configuration
│   ├── agents/                  # 26 expert agents
│   │   ├── sage.md             # Master orchestrator
│   │   ├── cim-domain-expert.md
│   │   ├── ddd-expert.md
│   │   └── ... (23 more)
│   └── settings.local.json      # Permissions
│
├── doc/                         # Documentation (what you're reading!)
│   ├── getting-started/         # Step-by-step guides
│   ├── research-integration/    # TRM, MQA/GQA, prototypical spaces
│   ├── domain-creation/         # Domain modeling workflow
│   └── ...
│
├── domains/                     # ← Your domains will go here
│   ├── organization/           # You'll create this in Step 3
│   ├── people/                 # You'll create this in Step 4
│   └── mortgage-underwriting/  # Your main domain (Step 6)
│
├── scripts/                     # Initialization and deployment scripts
└── examples/                    # Complete example CIMs for reference
```

---

## Step 1.5: Optional - Enter Nix Development Environment

If you have Nix installed (recommended):

```bash
# Enter reproducible development environment:
nix develop

# This provides:
# - Rust toolchain
# - NATS CLI tools
# - Development dependencies
# - Consistent environment across machines
```

**Without Nix**: You can still use cim-start! SAGE will guide you through manual dependency installation if needed.

---

## Step 1.6: Start Local NATS (Optional for Testing)

If you want to test locally before production deployment:

```bash
# Start NATS JetStream locally:
docker-compose up -d

# Verify NATS is running:
docker ps | grep nats

# Expected output:
# nats-server   nats:latest   ...   4222/tcp, 6222/tcp, 8222/tcp
```

**Note**: This is OPTIONAL for Step 1. You can run Domain-First workflow without infrastructure.

---

## Troubleshooting

### Claude Code Not Found

```bash
# Install Claude Code:
npm install -g @anthropic/claude

# Verify installation:
claude --version
```

### SAGE Not Responding

```bash
# Ensure you're in the repository root:
pwd  # Should show: .../mortgage-underwriting

# Re-initialize Claude Code:
claude init --force
```

### Nix Not Available

That's okay! Nix is optional. SAGE will guide you through manual dependency installation when needed.

---

## What's Next?

✅ You've cloned cim-start with your domain name
✅ You've initialized Claude Code and activated SAGE
✅ You understand your repository structure
✅ (Optional) You've started local NATS for testing

**Next Step**: [Step 2: Define Your Purpose →](02-define-purpose.md)

In Step 2, you'll create `purpose.yaml` - the foundational document that defines:
- What your CIM does
- What problem it solves
- What success looks like
- What's in scope (and out of scope)
- What external systems you'll observe

---

## Quick Commands Reference

```bash
# Clone with your domain name:
git clone https://github.com/TheCowboyAI/cim-start.git YOUR-DOMAIN-NAME

# Initialize Claude Code:
claude init

# Talk to SAGE:
@sage [your question or command]

# Enter Nix environment (optional):
nix develop

# Start local NATS (optional):
docker-compose up -d

# Stop local NATS:
docker-compose down
```

---

**Ready for Step 2?** → [Define Your Purpose](02-define-purpose.md)
