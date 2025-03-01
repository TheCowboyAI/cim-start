# The CIM Tech Stack

## [CIM](http://www.thecowboy.ai/cim) - Composable Information Machine

A CIM is a self-assembling, self-replicating, self-improving, self-aware, inteligence system.
We manage this by creating a Domain that encapsulates all the knowedge the machine cares about, incuding itself.

Everything in a CIM is Modular, made from smaller components. These components are in packages.  Packages are used to create modules, environments and configurations, these become "Subject based services".

### Subject-based services

These are similar in concept to a kubernetes pods, but run in a Nix Configuration instead of helm charts.
You *CAN* use kubernetes, but you are not *forced to*, nix can run anything.

Often endpoints or traditional micro-services that require a UI or converged configuration are difficult to configure in cloud platforms.
Subject-based services bundle a `bridge to nats`.
Even legacy code is able to Publish and Subscribe to Events.

Say I have a Service that uses ollama.
I use `services.ollama = {};` to configure ollama...
I create a nixosConfiguration for the service
Then I run it in a container.

I may have to setup web proxies and a bunch of other stuff to run this traditionally.
Instead, we now simply redirect all the inputs and outputs to a nats Subject.

A nats SERVER runs locally as a `leaf node` and may connect to any other nats server.

Many "services" won't run in wasi yet, or they can't compile to wasm.

We use plain old tcp and nats as a lattice to achieve most of our goals in this scenario. These containers build from `scratch` and only contain the service they provide. If we need a custom kernel, then a vm is appropriate.

We look at these with a `capability` and `provider` packaging scenario.

## NATS Enabled services

These are deployed into an environment that is connected solely by Message Bus... In this configuration, services don't talk to anything but nats.  Local-first gives us the option to leverage local hardware, then elevate the information to the distributed Domain.

### Event sourcing

Everything in Domains is intended to be Event sourced in a CIM. We will create many Domain Events to track relevant detail.
We will be working with more than one `Event Store`, they do orchestrate themselves within nats.

### Development friendly

Nix, Containers, Modules, DevShells, Overlays, Derivations... that sounds seriously steep.
This is precisely why we have a solid path to understand how all this works.
We have a genesis template that will walk you through everything from a blank slate.

Development should not be difficult...
Following rigid instructions usually is, so is learn your own path.
While we use mostly Rust, any language can be used.

A guided approach with absolutely clear separation of concerns and a ubiquitous language are our destination.

# [git](https://git-scm.com)

git is our starting point for a reason. A git repository is simply a portable collection of files that have the ability to track their changes. git accomplishes this with a Content Identifier for each commit that we use reactively to perform actions based on committed changes.

The very first thing to create a cim is to make the repository in which its configuration lives.

# [NixOS](https://nixos.org)

Nix and NixOS specifically give us the ability to perform the actions of the following tools in a single environment:

- Repeatable Linux From Scratch (build everything from source)
- Virtual Machines (QEMU/KVM)
- Containers (OCI, LXD, Bottles, systemd-nspawn)
- Package Management (Nix - 100,000+ Packages)
- git access to packages (pull a package source from git by version and build it)
- Multi-machine configuration management
- Remote deployment
- User management
- Shell management
- Desktop management
- Development environments
- Shared modules
- A Compiled Language we can generate from templates and tools
- Compiled configurations
- Immutable Content IDs

We can also call out to tools like docker, kubernetes, wireguard, terraform, ansible, or any other infrastructure tools you may already use... several have conversions to nix already available. Calling to a tool is fully testable and can be sandboxed in any way required.

We have a very opinionated way of structuring our nix environment, this is because we rely on a Domain.
If you think we are doing it `wrong`, please tell us, maybe we are.
Computing is a general tool, adapting it to your needs is where the Domain comes in, the Domain holds a lot of decision data and knowledge graphs. We really already know how to make a `computer` work, this is about applying that to a Domain.

### Training

- [Nix Pills](https://nixos.org/guides/nix-pills/)
- [Nix Dev](https://nix.dev/)
- [Learning Nix](https://github.com/spacekookie/learning-nix)
- [The Nix Hour](https://github.com/tweag/nix-hour)
- [Continuous Integration](https://nix.dev/tutorials/nixos/continuous-integration-github-actions)

# [NATS](https://nats.io)

NATS is our communication platform.
Everything in a CIM communicates through messages and nats controls that messaging environment.

NATS Provides:

- Streaming
- Message Sequencing
- Platform Independence
- Stream Processing Interface
- Event Stores
- Key Value Stores
- Object Stores
- Transaction Management

NATS is Subject-based, meaning all messages are routed by subject.
This enables us to have direct request/response interactions with Agents and APIs, and then broadcast results to a different Subject for a broadcast audience such as publish/subscribe fan-in or fan-out.

Anything with an API can be quickly and easily redirected to NATS messaging, even automated through AI.

Subjects are a language, and it has a structure.

### Training

- [Examples](https://natsbyexample.com/)
- [Videos](https://www.youtube.com/c/nats_messaging/videos)

# [neo4j](https://neo4j.com)

neo4j provides a robust graph database capability that we use to make relationships and manage graphs of the CIM.

### Training

[Cypher](https://graphacademy.neo4j.com/courses/cypher-fundamentals/)

# ollama

Ollama provides a capability to use many LLM Models in a common way. It also gives us a standard model to follow when creating embeddings and conversations with agents.

### Training

- [Rust Teacher](https://k33g.hashnode.dev/create-a-genai-rust-teacher)
- [Rust Ollama By Example](https://youtu.be/OcH-zT5VNgM)

# DNS

DNS is responsible for managing the Domain Naming System, Realms, Internet Domain Names, Object Names, indexing, and forwarding those names to external providers such as Cloudflare.

- Domain Objects all have names
- Network connected hosts all have names
- Objects in Object Stores all have names and a CID (ContentIdentifiers)
- Subjects in NATS are managed names

Naming therefore, is a Domain...
If you work with `names` use the `name` domain.

This becomes a domain on it's own that lets you work with names.
translate them, map them, list them, relate them, identify them, cache them, format them...
all this is done in a single domain with it's own contained tooling.

### Training

[Tutorial](https://www.isc.org/blogs/bind-management-webinar-series-2021/)

# IPA

We recommend using [KeyNode](https://github.com/thecowboyai/keynode), an offline Certificate of Authority root manager and PKI management module.

Identity, Policy and Audit is where we manage people.

- Single Sign On
- Radius Network Management
- OAUTH, OIDC, OLAP
- Role Management
- API Key Generation

### Training

- [Planning](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/8/html/planning_identity_management/index)
- [FreeIPA](https://youtu.be/lH7I-omZ4PA)

# [Vault Warden](https://github.com/dani-garcia/vaultwarden)

Vault Warden provides secure secrets management with a friendly interface.

### Training

- [Wiki](https://github.com/dani-garcia/vaultwarden/wiki)

# Web

[Iced](https://book.iced.rs/) provides capabilities for Native, Local-first UIs as well as Web Based. Follows our Messaging model architecture more closely.
[Leptos](https://leptos.dev/) provides capabilities for Web based Reactive Projections (such as dashboards or social interaction).

### Training

- [Moder Gui in Rist &amp; Iced](https://www.youtube.com/watch?v=72PyU1EIGY8)
- [Iced Book](https://book.iced.rs/)
- [Iced tutorial](https://leafheap.com/articles/iced-tutorial-version-0-12)
- [Leptos Book](https://book.leptos.dev/getting_started/index.html)
- [Leptos Video](https://youtu.be/GWB3vTWeLd4)

## Other Training Material

### NixOS

- [Script in any language](https://youtu.be/qRE6kf30u4g?si=qceqJ95RdFpQpSmi)
- [Nixos-anywhere](https://youtu.be/U_UwzMhixr8?si=4WrK3w7c85F-vzEi)
- [Deploying NixOS](https://youtu.be/vm-Sj1V529I?si=qH5_cx36joaMdXgs)
- [Nix Language](https://youtu.be/x-9bBPbsZwc?si=G-LgvrIoifDKo5rM)

#### DDD

- [Ubiquitous Language](https://youtu.be/yWDaBdV-SL8?si=5m04Kg0jcEKbKU19)
- [Bounded Contexts and Sub Domains](https://youtu.be/NvBsEnDgA4o?si=gcaIxE1YmmZdCI3b)
- [EventStorming](https://www.youtube.com/live/v4xLxmpAFdI?si=45pXJBAi6KQFYGlW)

#### NATS

- [Message Sending Toolkit](https://youtu.be/5NXvU17a-iU?si=lp4PdwBchDoWNYJs)
- [Connect ANY Auth System](https://youtu.be/VvGxrT-jv64?si=lWktD03kJUVvd5uT)
- [Leaf Nodes](https://youtu.be/WH55czo1BNk?si=wEAM6cL5IJrvoRDd)
- [Stream Processing](https://youtu.be/EA2Pco3EvpU?si=jSXVz45HCNBY0poy)

#### Conceptual Spaces

- [The Geometry of Thinking](https://youtu.be/Y3_zlm9DrYk?si=EXaCz4E2xOUuYcD9)
- [The Geometry of Meaning](https://youtu.be/L0X9mEe9aY0?si=UWrBkWgMI8K-jmgr)
- [The Shape of Language](https://youtu.be/0PbaEvm22G0?si=nesSqFOm4RUQQqQO)
- [A Thousand Brains](https://youtu.be/XK-Vksr3IT8?si=vJIthdJ419bVfl6_)
- [Conceptual Spaces and Social Interactions](https://youtu.be/XK-Vksr3IT8?si=vJIthdJ419bVfl6_)
- [Conceptual Blending](https://youtu.be/53QRyH3mVVM?si=aZhasguPEQvFVzMf)

#### Category Theory

- [Category Theory for the working Programmer](https://youtube.com/playlist?list=PLbgaMIhjbmEnaH_LTkxLI7FMa2HsnawM_&si=us29wC4bq3Pn_Zse)
- [Graph Data Models](https://youtu.be/SmOExZx9TaU?si=A-MEe1nbv1caQ33m)
- [Interface Based Design](https://youtu.be/JMP6gI5mLHc?si=dSf0pSmBRoQ6Gio9)

#### AI

- [Floneum](https://github.com/floneum/floneum)
- [Agents as MicroServices](https://youtu.be/_aTEI3ISkQA?si=moD3HZOpe3tEIW4A)
- [Llama3 Fine-tuning](https://youtu.be/pK8u4QfdLx0?si=fnwTCyebryT8fhRG)
- [AI = Language](https://youtu.be/7m1x66psgqA?si=8xl9BDon42gbTuMZ)
- [Long Term Memory and Self Improvement](https://youtu.be/7LWTZqksmSg?si=X6i4kITRNUYWeIby)

#### Programming

- [Graph Visualization](https://youtu.be/4x3sK-URLF4?si=c1LVRmTqGzNNeHOh)
- [Visualizing Data](https://youtu.be/5pCdw-PV0Js?si=EDkiIzjGK1XZJM7R)
- [Building WASM Apps with Rust](https://youtu.be/ie13kswrWu4?si=rnln5PxRjQMiui5j)
- [Build a reactive system](https://youtu.be/GWB3vTWeLd4?si=_KUYHYwJt_YmD_v4)

#### Business Models

- [Mastering Value Propositions](https://youtu.be/35ST-37PPXc?si=eSR88qxEbHCeAqV0)
- [Testing before building is the key to success](https://youtu.be/LRGkWhjZfd4?si=iKqXdxdQE6oPsP94)
