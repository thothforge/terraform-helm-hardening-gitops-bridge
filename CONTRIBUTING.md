# Contributing to Terraform Hardening GitOps Bridge Module

Thank you for your interest in contributing to the Terraform Hardening GitOps Bridge Module! This document provides guidelines and information for contributors.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Contributing Guidelines](#contributing-guidelines)
- [Pull Request Process](#pull-request-process)
- [Testing](#testing)
- [Documentation](#documentation)
- [Release Process](#release-process)

## Code of Conduct

This project adheres to a code of conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

## Getting Started

### Prerequisites

Before contributing, ensure you have:

- **Terraform**: Version >= 1.0
- **AWS CLI**: Configured with appropriate permissions
- **kubectl**: For Kubernetes cluster access
- **Git**: For version control
- **Pre-commit**: For code quality checks
- **terraform-docs**: For documentation generation

### Development Tools

Install the required development tools:

```bash
# Install pre-commit
pip install pre-commit

# Install terraform-docs
brew install terraform-docs  # macOS
# or
curl -sSLo ./terraform-docs.tar.gz https://terraform-docs.io/dl/v0.16.0/terraform-docs-v0.16.0-$(uname)-amd64.tar.gz
tar -xzf terraform-docs.tar.gz
chmod +x terraform-docs
sudo mv terraform-docs /usr/local/bin/

# Install tflint
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
```

## Development Setup

1. **Fork and Clone**
```bash
# Fork the repository on GitHub
# Clone your fork
git clone https://github.com/YOUR_USERNAME/terraform-hardening-gitops-bridge.git
cd terraform-hardening-gitops-bridge
```

2. **Install Pre-commit Hooks**
```bash
pre-commit install
```

3. **Create Development Branch**
```bash
git checkout -b feature/your-feature-name
```

## Contributing Guidelines

### Code Style

#### Terraform Code Style
- Use consistent indentation (2 spaces)
- Follow Terraform naming conventions
- Use descriptive variable and resource names
- Add comments for complex logic
- Use locals for repeated values

#### Example:
```hcl
# Good
resource "aws_security_group" "argocd_ingress" {
  name_prefix = "${var.cluster_name}-argocd-ingress"
  vpc_id      = var.vpc_id
  
  # Allow HTTPS traffic from specified CIDR blocks
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }
  
  tags = merge(var.tags, {
    Name = "${var.cluster_name}-argocd-ingress-sg"
  })
}

# Bad
resource "aws_security_group" "sg1" {
  name = "sg1"
  vpc_id = var.vpc_id
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

#### Variable Definitions
- Always include descriptions
- Use appropriate types
- Add validation where applicable
- Set sensible defaults

```hcl
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.cluster_name))
    error_message = "The cluster_name must consist of alphanumeric characters and hyphens only."
  }
}
```

### Commit Messages

Follow conventional commit format:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

Examples:
```
feat(addons): add support for Istio service mesh

Add configuration options for Istio service mesh integration
including ingress gateway and sidecar injection settings.

Closes #123

fix(security): resolve security group rule conflicts

Update security group rules to prevent conflicts when multiple
ingress controllers are enabled simultaneously.

docs(readme): update troubleshooting section

Add common debugging commands and solutions for DNS resolution
issues and load balancer configuration problems.
```

### Branch Naming

Use descriptive branch names:
- `feature/add-istio-support`
- `fix/security-group-conflicts`
- `docs/update-readme`
- `refactor/simplify-locals`

## Pull Request Process

### Before Submitting

1. **Run Pre-commit Checks**
```bash
pre-commit run --all-files
```

2. **Validate Terraform**
```bash
terraform fmt -recursive
terraform validate
```

3. **Generate Documentation**
```bash
terraform-docs markdown table --output-file README.md .
```

4. **Test Your Changes**
```bash
# Run any available tests
make test

# Test with example configurations
cd examples/simple
terraform init
terraform plan
```

### Pull Request Template

When creating a pull request, include:

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Terraform validate passes
- [ ] Pre-commit hooks pass
- [ ] Manual testing completed
- [ ] Documentation updated

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No breaking changes (or clearly documented)
```

### Review Process

1. **Automated Checks**: All automated checks must pass
2. **Code Review**: At least one maintainer review required
3. **Testing**: Changes must be tested in a development environment
4. **Documentation**: Updates to documentation must be included

## Testing

### Manual Testing

1. **Create Test Environment**
```bash
# Use the simple example for basic testing
cd examples/simple
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

2. **Deploy and Test**
```bash
terraform init
terraform plan
terraform apply

# Test functionality
kubectl get pods -n argocd
kubectl get applications -n argocd
```

3. **Cleanup**
```bash
terraform destroy
```

### Integration Testing

For significant changes, test with:
- Multiple Kubernetes versions
- Different AWS regions
- Various addon combinations
- Different deployment patterns (single vs hub-spoke)

## Documentation

### README Updates

When making changes that affect usage:

1. Update relevant sections in README.md
2. Add new configuration examples
3. Update troubleshooting guides
4. Add FAQ entries if needed

### Code Documentation

- Add inline comments for complex logic
- Document any assumptions or limitations
- Include examples in variable descriptions

### Terraform Docs

The module uses terraform-docs for automatic documentation generation:

```bash
# Generate documentation
terraform-docs markdown table --output-file README.md .

# The generated content will be placed between:
# <!-- BEGIN_TF_DOCS -->
# <!-- END_TF_DOCS -->
```

## Release Process

### Versioning

This project follows [Semantic Versioning](https://semver.org/):

- **MAJOR**: Incompatible API changes
- **MINOR**: Backward-compatible functionality additions  
- **PATCH**: Backward-compatible bug fixes

### Release Steps

1. **Update Version**
   - Update version in relevant files
   - Update CHANGELOG.md

2. **Create Release PR**
   - Include all changes since last release
   - Update documentation

3. **Tag Release**
```bash
git tag -a v1.2.0 -m "Release version 1.2.0"
git push origin v1.2.0
```

4. **Create GitHub Release**
   - Use the tag created above
   - Include changelog in release notes

## Getting Help

### Communication Channels

- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and general discussion
- **Pull Request Comments**: For code-specific discussions

### Maintainer Response Time

- **Issues**: We aim to respond within 48 hours
- **Pull Requests**: Initial review within 72 hours
- **Security Issues**: Within 24 hours

## Recognition

Contributors will be recognized in:
- CHANGELOG.md for significant contributions
- GitHub contributors list
- Release notes for major contributions

Thank you for contributing to the Terraform Hardening GitOps Bridge Module!
