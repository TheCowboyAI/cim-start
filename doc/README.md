# CIM-Start Documentation

**Welcome to CIM-Start** - The template for creating Composable Information Machines.

---

## 🚀 Quick Navigation

### New to CIM? Start Here 👇

**[Getting Started →](getting-started/01-clone-and-initialize.md)**

Follow our 7-step guided journey:
1. Clone and Initialize
2. Define Purpose
3. Create Organization
4. Add People
5. Choose Your Path
6. Build Domain OR Setup Infrastructure
7. Deploy Your CIM

---

## 📚 Documentation Sections

### 🎯 [Getting Started](getting-started/)
Step-by-step guide from cloning to deployment. Perfect for first-time CIM builders.

- **Time to first purpose**: ~5 minutes
- **Time to working domain**: 1-2 hours
- **Time to deployment**: 2-4 hours

### 🧬 [Research Integration](research-integration/)
TRM-based recursive reasoning, prototypical spaces, and attention mechanisms.

**Research Foundations**:
- Tiny Recursive Model (TRM) - arXiv:2510.04871v1
- Multi-Query Attention (MQA) - arXiv:1911.02150v1
- Grouped-Query Attention (GQA) - arXiv:2305.13245v3

**Key Concepts**:
- Observe → Refine → Distill (3-phase process)
- n=6 recursive refinement iterations
- T=3 abstraction levels (Strategic/Tactical/Operational)
- Category-Query Attention for semantic understanding

### 🏗️ [Domain Creation](domain-creation/)
Build your domain using prototypical space creation and DDD.

**Workflow**:
1. Define purpose and scope
2. Observe external systems (no coupling)
3. Refine recursively (6 iterations)
4. Distill to DDD artifacts
5. Create geometric conceptual spaces

### 🌐 [Infrastructure](infrastructure/)
NATS, Nix, cim-keys, and network topology.

**Topics**:
- NATS JetStream setup
- Nix flake configuration
- PKI and security (cim-keys integration)
- Network topology patterns
- Deployment strategies

### 🤖 [Agent System](agent-system/)
SAGE orchestration and 26 specialized expert agents.

**Agents**:
- @sage - Master orchestrator
- @cim-domain-expert - CIM-specific architecture
- @ddd-expert - Domain-driven design
- @conceptual-spaces-expert - Geometric semantics
- ... and 22 more specialized experts

### 💻 [Development](development/)
Implementation guides, testing patterns, and advanced topics.

**Topics**:
- BDD/TDD patterns
- Module assembly (using cim-* ecosystem)
- Integration strategies
- Advanced patterns

### 📖 [Reference](reference/)
Quick reference for schemas, notation, and troubleshooting.

**Quick Lookups**:
- YAML schemas
- Mathematical notation
- NATS subject patterns
- Common issues and solutions

### 🎓 [Examples](examples/)
Complete end-to-end examples of real CIMs.

**Available Examples**:
- Mortgage Lending CIM
- Inventory Management CIM
- Customer Service CIM

---

## 🎯 Choose Your Learning Path

### Path A: Domain-First (Recommended for Learning)

**Best if you**:
- Are new to CIM
- Want to understand domain modeling first
- Have external systems to observe
- Can deploy infrastructure later

**Journey**:
Purpose → Organization → People → **Observe → Refine → Distill** → cim-keys

### Path B: Infrastructure-First (Recommended for Production)

**Best if you**:
- Are deploying to production
- Have infrastructure planned
- Need security/PKI upfront
- Have infrastructure expertise

**Journey**:
Purpose → Organization → People → **cim-keys → NATS → Network** → Domain

---

## 🔑 Core Principles

1. **Purpose First**: Define WHY before HOW
2. **People Matter**: Organization and People are foundational domains
3. **External Observation**: Never couple, always distill
4. **Recursive Refinement**: Simple observations + deep reasoning
5. **Mathematical Foundation**: Category Theory, Graph Theory, Conceptual Spaces
6. **SAGE Orchestration**: Multi-agent workflows guide the journey
7. **Less is More**: Minimal structures with maximal understanding

---

## 🆘 Need Help?

- **Getting stuck?** Check [troubleshooting](reference/troubleshooting.md)
- **Want deeper understanding?** Read [core concepts](../CLAUDE.md#core-concepts)
- **Need agent help?** Use `@sage` to orchestrate experts
- **Found a bug?** Open an issue on GitHub

---

## 📦 What You Get

When you clone cim-start, you get:

✅ **SAGE** - Master orchestrator agent
✅ **26 Expert Agents** - Specialized guidance
✅ **Nix Environment** - Reproducible development
✅ **NATS Infrastructure** - Event-driven backbone
✅ **Domain Templates** - Quick start structures
✅ **Complete Examples** - Real-world CIMs
✅ **Research Integration** - TRM, MQA/GQA, prototypical spaces
✅ **Two Development Paths** - Domain-First OR Infrastructure-First

---

## 🚦 Status of This Template

**Version**: 2.0.0 (Post-TRM Integration)
**Status**: Active Development
**Last Updated**: 2025-11-10

**Recent Changes**:
- ✨ Added TRM-based prototypical space creation
- ✨ Integrated Category-Query Attention mechanisms
- ✨ New two-path workflow (Domain vs Infrastructure)
- ✨ Purpose-first initialization
- ✨ Research-grounded domain discovery

---

## 📄 License

Copyright © 2025 Cowboy AI, LLC
Licensed under [LICENSE](../LICENSE)

---

**Ready to begin?** → [Start with Step 1: Clone and Initialize](getting-started/01-clone-and-initialize.md)
