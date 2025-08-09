# Security Policy

Copyright 2025 - Cowboy AI, LLC

## Supported Versions

We actively support the following versions of CIM-Start with security updates:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take the security of CIM-Start seriously. If you discover a security vulnerability, please follow these steps:

### Reporting Process

1. **Do NOT** open a public GitHub issue for security vulnerabilities
2. Email security findings to: security@cowboy-ai.com
3. Include the following information:
   - Description of the vulnerability
   - Steps to reproduce the issue
   - Potential impact assessment
   - Any proof-of-concept code (if applicable)

### What to Expect

- **Acknowledgment**: We will acknowledge receipt of your report within 24 hours
- **Initial Assessment**: We will provide an initial assessment within 72 hours
- **Updates**: We will keep you informed of our progress toward a fix
- **Resolution**: We aim to resolve critical vulnerabilities within 7 days
- **Credit**: We will credit you in our security advisory (unless you prefer to remain anonymous)

### Security Best Practices

When using CIM-Start, follow these security guidelines:

#### NATS Security

- Use TLS encryption for all NATS connections
- Implement proper authentication and authorization
- Regularly rotate credentials
- Monitor access logs

#### Domain Security

- Validate all input data in command handlers
- Implement proper authorization checks
- Never log sensitive information in events
- Use encryption for sensitive data at rest

#### Infrastructure Security

- Keep Docker images updated
- Use secrets management for credentials
- Implement network segmentation
- Enable audit logging

#### Development Security

- Never commit secrets to version control
- Use environment variables for configuration
- Implement secure coding practices
- Regular dependency updates

## Security Advisories

Security advisories will be published:

- On our GitHub repository security tab
- In release notes for security patches
- Via email to registered security contacts

## Scope

This security policy covers:

- CIM-Start core framework
- Included domain examples
- Infrastructure templates
- Documentation and guides

## Out of Scope

This policy does not cover:

- Third-party dependencies (report to respective maintainers)
- User-specific domain implementations
- Infrastructure configured by users
- Issues in development/testing environments

## Security Features

CIM-Start includes several security features:

- Event integrity validation
- Command authentication hooks
- Audit trail capabilities
- Secure defaults in templates

## Contact

For security-related questions or concerns:

- Email: security@cowboy-ai.com
- Response time: Within 24 hours
- PGP key: Available upon request

## Recognition

We believe in responsible disclosure and will recognize security researchers who:

- Follow our reporting process
- Allow reasonable time for fixes
- Do not publicly disclose until resolved
- Act in good faith

Thank you for helping keep CIM-Start and its users secure!