# Contributing to CIM-Start

Copyright 2025 - Cowboy AI, LLC

Thank you for your interest in contributing to CIM-Start! This document provides guidelines and information for contributors.

## Code of Conduct

By participating in this project, you agree to abide by our Code of Conduct (see CODE_OF_CONDUCT.md).

## Getting Started

1. Fork the repository
2. Clone your fork locally
3. Set up the development environment using Nix: `nix develop`
4. Create a new branch for your changes: `git checkout -b feature/your-feature-name`

## Development Environment

### Prerequisites

- Nix package manager (recommended)
- Docker and Docker Compose (for NATS)
- Git

### Setup

```bash
# Clone the repository
git clone https://github.com/thecowboyai/cim-start.git
cd cim-start

# Enter development environment
nix develop

# Start NATS for testing
docker-compose up -d
```

## Making Changes

### Domain Modeling

When contributing domain models:

1. Follow event sourcing principles
2. Use past-tense naming for events
3. Ensure aggregates maintain consistency boundaries
4. Document business rules and policies

### Code Style

- Follow the existing code patterns in the repository
- Use clear, descriptive names for events, commands, and aggregates
- Add appropriate documentation for complex business logic
- Include copyright headers in new files

### Testing

- Write tests for new functionality
- Ensure all existing tests pass
- Test with real NATS infrastructure when possible
- Document test scenarios in commit messages

## Submitting Changes

1. Ensure your branch is up to date with main
2. Run the test suite: `nix flake check`
3. Commit your changes with clear, descriptive messages
4. Push to your fork
5. Create a pull request

### Commit Messages

Use clear, descriptive commit messages:

```
feat: add customer registration domain events

- Add CustomerRegistered event
- Add RegisterCustomer command  
- Update domain definition YAML

Closes #123
```

### Pull Request Process

1. Use the provided PR template
2. Fill out all relevant sections
3. Link related issues
4. Ensure CI passes
5. Request review from maintainers

## Types of Contributions

### Documentation

- Improve existing documentation
- Add examples and tutorials
- Fix typos and clarify language
- Translate documentation

### Domain Models

- Add new domain examples
- Improve existing domain definitions
- Add business rule implementations
- Create domain-specific templates

### Infrastructure

- Improve NATS configurations
- Add deployment options
- Enhance CI/CD pipelines
- Add monitoring and observability

### Tooling

- Improve development experience
- Add code generation tools
- Create validation utilities
- Enhance testing infrastructure

## Reporting Issues

Use GitHub Issues to report:

- Bugs and errors
- Feature requests
- Documentation issues
- Infrastructure problems

Please use the appropriate issue template and provide:

- Clear description of the issue
- Steps to reproduce (for bugs)
- Expected vs actual behavior
- Environment details
- Relevant logs or error messages

## Community Guidelines

- Be respectful and inclusive
- Help others learn and contribute
- Share knowledge and experiences
- Focus on constructive feedback
- Follow project conventions

## Questions?

- Check existing documentation first
- Search existing issues and discussions
- Ask questions in GitHub Discussions
- Reach out to maintainers

## Recognition

Contributors will be recognized in:

- CONTRIBUTORS.md file
- Release notes
- Project documentation
- Community highlights

Thank you for contributing to CIM-Start and the broader Composable Information Machine ecosystem!