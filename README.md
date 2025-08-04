

# Terraform Hardening GitOps Bridge Module

[![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![ArgoCD](https://img.shields.io/badge/argo-EF7B4D?style=for-the-badge&logo=argo&logoColor=white)](https://argoproj.github.io/cd/)


A comprehensive Terraform module that provides a hardened GitOps bridge for Amazon EKS clusters, implementing security best practices and enterprise-grade configurations for GitOps workflows using ArgoCD.

## 📖 Table of Contents

- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Architecture](#️-architecture)
- [Quick Start](#-quick-start)
- [Examples](#-examples)
- [Configuration Options](#-configuration-options)
- [Security Best Practices](#-security-best-practices)
- [Deployment Patterns](#️-deployment-patterns)
- [Monitoring and Observability](#-monitoring-and-observability)
- [Performance Optimization](#-performance-optimization)
- [Advanced Security Configuration](#-advanced-security-configuration)
- [DNS and Ingress Configuration](#-dns-and-ingress-configuration)
- [Customization Options](#-customization-options)
- [Cost Optimization](#-cost-optimization)
- [Best Practices](#-best-practices)
- [Operational Procedures](#-operational-procedures)
- [FAQ](#-faq)
- [Additional Resources](#-additional-resources)

- [Contributing](#-contributing)
- [License](#-license)
- [Support](#-support)

## 🚀 Features

### Core Capabilities
- **GitOps Integration**: Seamless integration with ArgoCD for GitOps workflows
- **Security Hardening**: Enterprise-grade security configurations and best practices
- **Multi-Repository Support**: Support for addons, platform, and workloads repositories
- **Flexible Deployment**: Single cluster or hub-spoke architecture support
- **Comprehensive Addons**: Pre-configured essential Kubernetes addons

### Security Features
- **RBAC Integration**: Role-based access control with customizable permissions
- **SSO Support**: Microsoft Entra ID (Azure AD) integration
- **Certificate Management**: Automated SSL/TLS certificate provisioning
- **Network Security**: Security group management and ingress controls
- **Secrets Management**: Integration with AWS Secrets Manager and External Secrets

### Networking & Infrastructure
- **Load Balancer Integration**: AWS Load Balancer Controller support
- **DNS Management**: External DNS with Route53 integration
- **Service Mesh**: Optional Istio service mesh integration
- **Ingress Management**: Configurable ingress controllers and rules

### Monitoring & Observability
- **Metrics Collection**: Metrics Server and custom metrics support
- **Logging**: Grafana Loki integration for centralized logging
- **Workflow Management**: Argo Workflows for CI/CD pipelines

## 📋 Prerequisites

Before using this module, ensure you have:

- **Terraform**: Version >= 1.0
- **AWS CLI**: Configured with appropriate permissions
- **kubectl**: For Kubernetes cluster access
- **Existing EKS Cluster**: The module requires an existing EKS cluster
- **VPC and Subnets**: Properly configured networking infrastructure
- **Route53 Zones**: For DNS management (optional)

### Required AWS Permissions

The module requires the following AWS permissions:
- EKS cluster management
- IAM role and policy management
- VPC and security group management
- Route53 DNS management
- ACM certificate management
- Secrets Manager access

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        GitOps Bridge Architecture               │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │   Addons    │    │  Platform   │    │ Workloads   │         │
│  │ Repository  │    │ Repository  │    │ Repository  │         │
│  └─────────────┘    └─────────────┘    └─────────────┘         │
│         │                   │                   │              │
│         └───────────────────┼───────────────────┘              │
│                             │                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    ArgoCD                               │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │   │
│  │  │   Server    │  │ Application │  │ Repository  │     │   │
│  │  │             │  │ Controller  │  │   Server    │     │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘     │   │
│  └─────────────────────────────────────────────────────────┘   │
│                             │                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                 EKS Cluster                             │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │   │
│  │  │   Addons    │  │  Platform   │  │ Application │     │   │
│  │  │             │  │ Components  │  │ Workloads   │     │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘     │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## 🚦 Quick Start

### Basic Usage

```hcl
module "gitops_bridge" {
  source = "path/to/terraform-hardening-gitops-bridge"

  # Basic Configuration
  enable       = true
  project_name = "my-project"
  
  # EKS Cluster Configuration
  cluster_name                         = "my-eks-cluster"
  cluster_version                      = "1.30"
  cluster_endpoint                     = "https://xxxxx.gr7.us-west-2.eks.amazonaws.com"
  cluster_platform_version             = "eks.1"
  cluster_certificate_authority_data   = "LS0tLS1CRUdJTi..."
  oidc_provider_arn                    = "arn:aws:iam::123456789012:oidc-provider/..."

  # Network Configuration
  vpc_id             = "vpc-12345678"
  private_subnet_ids = ["subnet-12345678", "subnet-87654321"]
  public_subnet_ids  = ["subnet-abcdefgh", "subnet-hgfedcba"]

  # GitOps Configuration
  gitops_addons_org  = "git@github.com:my-org"
  gitops_addons_repo = "my-addons-repo"
  
  # Basic Addons
  addons = {
    enable_aws_load_balancer_controller = true
    enable_metrics_server               = true
    enable_external_secrets             = true
  }

  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

### Advanced Configuration

For more complex scenarios, see the [complete example](./examples/complete/) which includes:
- SSO integration
- Custom certificates
- Istio service mesh
- Advanced networking
- User management

## 📚 Examples

| Example | Description | Use Case |
|---------|-------------|----------|
| [Simple](./examples/simple/) | Basic GitOps bridge setup | Development environments |
| [Complete](./examples/complete/) | Full-featured configuration | Production environments |

## 🔧 Configuration Options

### GitOps Repositories

The module supports three types of repositories:

1. **Addons Repository**: Contains Kubernetes addons and operators
2. **Platform Repository**: Contains platform-level configurations
3. **Workloads Repository**: Contains application workloads

### Supported Addons

| Addon | Description | Default |
|-------|-------------|---------|
| AWS Load Balancer Controller | Manages AWS ALB/NLB | ✅ |
| Metrics Server | Kubernetes metrics collection | ✅ |
| External Secrets | Secrets management | ✅ |
| External DNS | DNS management | ✅ |
| Secrets Store CSI Driver | CSI secrets integration | ✅ |
| Karpenter | Node autoscaling | ❌ |
| Cluster Autoscaler | Traditional autoscaling | ❌ |
| Istio | Service mesh | ❌ |
| Argo Workflows | Workflow engine | ✅ |
| Grafana Loki | Log aggregation | ✅ |

### Security Configuration

#### SSO Integration
```hcl
enable_sso    = true
tenant_id     = "your-tenant-id"
client_id     = "your-client-id"
client_secret = "your-client-secret"
```

#### User Management
```hcl
user_management_config = {
  enabled                  = true
  store_in_secrets_manager = true
  password_length          = 16
  default_role            = "role:readonly"
}
```

## 🔒 Security Best Practices

This module implements several security best practices:

1. **Least Privilege Access**: RBAC configurations follow least privilege principles
2. **Network Segmentation**: Security groups and network policies
3. **Secrets Management**: Integration with AWS Secrets Manager
4. **Certificate Management**: Automated SSL/TLS certificate provisioning
5. **Audit Logging**: Comprehensive logging and monitoring



## 🏛️ Deployment Patterns

### Single Cluster Pattern
Ideal for development and small-scale production environments:

```hcl
gitops_deployment_type = "single"
```

### Hub-Spoke Pattern
Recommended for enterprise environments with multiple clusters:

```hcl
gitops_deployment_type = "hub-spoke"
```

## 📊 Monitoring and Observability

### Built-in Monitoring Stack

The module includes comprehensive monitoring capabilities:

- **Metrics Server**: Core Kubernetes metrics
- **Grafana Loki**: Centralized logging
- **Argo Workflows**: CI/CD pipeline monitoring
- **External DNS**: DNS resolution monitoring

### Custom Metrics Configuration

```hcl
addons = {
  enable_metrics_server = true
  enable_grafana_loki   = true
}
```

### Accessing Monitoring Dashboards

```bash
# Port forward to ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Access ArgoCD at https://localhost:8080
```

## ⚡ Performance Optimization

### Node Scaling Options

#### Karpenter (Recommended)
```hcl
addons = {
  enable_karpenter = true
}

karpenter_discovery_tag = "project"
```

#### Cluster Autoscaler
```hcl
addons = {
  enable_cluster_autoscaler = true
}
```

### VPC CNI Configuration

#### Default Configuration
```hcl
vpc_cni_conf_mode = "default_cfg"
```

#### Custom Configuration (for secondary subnets)
```hcl
vpc_cni_conf_mode = "custom_cfg"
```

## 🔐 Advanced Security Configuration

### Network Security

#### Custom Security Groups
```hcl
core_cluster_apps_ingress_cidr = ["10.0.0.0/8", "172.16.0.0/12"]
```

#### Certificate Management
```hcl
conf_metadata = {
  enable_custom_certificates = true
}

internal_apps_domain_names = [
  "app1.internal.example.com",
  "app2.internal.example.com"
]
```

### Secrets Management

#### AWS Secrets Manager Integration
```hcl
addons = {
  enable_external_secrets                      = true
  enable_secrets_store_csi_driver              = true
  enable_secrets_store_csi_driver_provider_aws = true
}
```

#### User Management with Secrets
```hcl
user_management_config = {
  enabled                  = true
  store_in_secrets_manager = true
  password_length          = 16
  bcrypt_cost              = 10
}
```

## 🌐 DNS and Ingress Configuration

### External DNS Setup
```hcl
external_dns_domain_filters = ["example.com", "internal.example.com"]
private_route53_zone_arn    = ["arn:aws:route53:::hostedzone/Z123456789"]
public_route53_zone_arn     = ["arn:aws:route53:::hostedzone/Z987654321"]
```

### ArgoCD Ingress Configuration
```hcl
enable_argo_ingress = true
argo_host_dns = {
  domain_name            = "argocd.example.com"
  zone_id                = "Z123456789"
  aws_load_balancer_type = "internet-facing"
  validation             = "dns"
}
```

## 🔧 Customization Options

### GitOps Repository Configuration

#### Multiple Repository Support
```hcl
gitops_repositories = [
  "https://github.com/your-org/addons-repo",
  "https://github.com/your-org/platform-repo",
  "https://github.com/your-org/workloads-repo"
]
```

#### Repository Structure
```
your-gitops-repo/
├── addons/
│   ├── aws-load-balancer-controller/
│   ├── external-dns/
│   └── metrics-server/
├── platform/
│   ├── namespaces/
│   ├── rbac/
│   └── policies/
└── workloads/
    ├── app1/
    ├── app2/
    └── shared/
```

### Service Mesh Integration

#### Istio Configuration
```hcl
addons = {
  enable_istio = true
}

conf_metadata = {
  enable_istio_extensions = true
}
```

## 📈 Cost Optimization

### Resource Tagging Strategy
```hcl
tags = {
  Environment   = "production"
  Project       = "my-project"
  Owner         = "platform-team"
  CostCenter    = "engineering"
  Backup        = "required"
  Monitoring    = "enabled"
}
```

### Right-sizing Recommendations

1. **Use Karpenter** for dynamic node scaling
2. **Enable spot instances** where appropriate
3. **Monitor resource utilization** with metrics server
4. **Implement resource quotas** per namespace









## 🎯 Best Practices

### Repository Management

#### Branch Strategy
```
main/master (production)
├── develop (staging)
├── feature/new-addon
└── hotfix/security-patch
```

#### Commit Message Convention
```
feat: add external-secrets addon
fix: resolve DNS resolution issue
docs: update README with new examples
chore: update addon versions
```

### Security Hardening

#### Network Policies
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
```

#### Pod Security Standards
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

### Resource Management

#### Resource Quotas
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: production
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
```

#### Limit Ranges
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: default-limits
  namespace: production
spec:
  limits:
  - default:
      cpu: 500m
      memory: 512Mi
    defaultRequest:
      cpu: 100m
      memory: 128Mi
    type: Container
```

### Monitoring and Alerting

#### Key Metrics to Monitor
- ArgoCD application sync status
- Kubernetes cluster health
- Resource utilization
- Security events
- DNS resolution times

#### Alerting Rules
```yaml
groups:
- name: argocd
  rules:
  - alert: ArgoCDAppNotSynced
    expr: argocd_app_info{sync_status!="Synced"} == 1
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "ArgoCD application {{ $labels.name }} is not synced"
```

## 🔧 Operational Procedures

### Disaster Recovery

#### Backup Strategy
1. **Git Repository Backups**
   - Multiple remote repositories
   - Regular automated backups
   - Version control history preservation

2. **Cluster State Backups**
```bash
# Backup ArgoCD configuration
kubectl get applications -n argocd -o yaml > argocd-apps-backup.yaml

# Backup secrets (encrypted)
kubectl get secrets --all-namespaces -o yaml > secrets-backup.yaml
```

3. **Recovery Procedures**
```bash
# Restore ArgoCD applications
kubectl apply -f argocd-apps-backup.yaml

# Verify restoration
kubectl get applications -n argocd
```

### Maintenance Windows

#### Pre-maintenance Checklist
- [ ] Notify stakeholders
- [ ] Backup current state
- [ ] Prepare rollback plan
- [ ] Test in staging environment

#### During Maintenance
```bash
# Scale down non-essential workloads
kubectl scale deployment non-essential-app --replicas=0

# Perform maintenance tasks
terraform apply

# Verify system health
kubectl get pods --all-namespaces
```

#### Post-maintenance Validation
```bash
# Check ArgoCD sync status
kubectl get applications -n argocd

# Verify addon functionality
kubectl get pods -n kube-system

# Test application endpoints
curl -k https://argocd.example.com/healthz
```

### Scaling Considerations

#### Horizontal Scaling
```hcl
# Enable Karpenter for automatic node scaling
addons = {
  enable_karpenter = true
}

# Configure node pools
karpenter_discovery_tag = "environment"
```

#### Vertical Scaling
```yaml
# ArgoCD server resource limits
resources:
  limits:
    cpu: 2
    memory: 4Gi
  requests:
    cpu: 1
    memory: 2Gi
```



## 📚 Additional Resources

### Module Documentation
- [Troubleshooting Guide](./TROUBLESHOOTING.md) - Comprehensive troubleshooting and debugging guide
- [Migration Guide](./MIGRATION.md) - Step-by-step migration from other GitOps solutions
- [Upgrade Guide](./UPGRADE.md) - Version upgrade instructions and compatibility matrix
- [Examples](./examples/) - Working configuration examples

### External Documentation
- [ArgoCD Official Documentation](https://argo-cd.readthedocs.io/)
- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
- [External DNS Documentation](https://github.com/kubernetes-sigs/external-dns)
- [Karpenter Documentation](https://karpenter.sh/)

### Community Resources
- [GitOps Working Group](https://github.com/gitops-working-group)
- [CNCF ArgoCD Project](https://www.cncf.io/projects/argo/)
- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

```bash
# Clone the repository
git clone <repository-url>

# Install pre-commit hooks
pre-commit install

# Run tests
make test

# Generate documentation
terraform-docs .
```

## 📄 License

This module is licensed under the [MIT License](LICENSE).

## 🆘 Support

For help with this module:

- **Documentation**: Check the [examples](./examples/) and this README
- **Troubleshooting**: See the [Troubleshooting Guide](./TROUBLESHOOTING.md) for common issues and solutions
- **Migration**: Follow the [Migration Guide](./MIGRATION.md) for migrating from other GitOps solutions
- **Upgrades**: Use the [Upgrade Guide](./UPGRADE.md) for version upgrades
- **Issues**: Report bugs via GitHub Issues
- **Discussions**: Join our community discussions

---

<!-- BEGIN_TF_DOCS -->
<!--
** DO NOT EDIT THIS FILE
** This file was automatically generated by using Terraform Docs
** 1) Make all changes on files under docs/*.md
** 2) Run `terraform-docs .` to rebuild this file
**
** By following this practice we ensure standard and high-quality across multiple projects.
** DO NOT EDIT THIS FILE
-->



## Example
```hcl
################################################################################
# Complete Example - Terraform Hardening GitOps Bridge
################################################################################

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data sources to get existing EKS cluster information
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  
  tags = {
    Type = "Private"
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  
  tags = {
    Type = "Public"
  }
}

# Configure Kubernetes provider
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# Configure Helm provider
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

################################################################################
# GitOps Bridge Module
################################################################################

module "gitops_bridge" {
  source = "../../"

  # Basic Configuration
  enable       = true
  project_name = var.project_name
  
  # EKS Cluster Configuration
  cluster_name                         = var.cluster_name
  cluster_version                      = data.aws_eks_cluster.cluster.version
  cluster_endpoint                     = data.aws_eks_cluster.cluster.endpoint
  cluster_platform_version             = data.aws_eks_cluster.cluster.platform_version
  cluster_certificate_authority_data   = data.aws_eks_cluster.cluster.certificate_authority[0].data
  oidc_provider_arn                    = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer

  # Network Configuration
  vpc_id             = var.vpc_id
  private_subnet_ids = data.aws_subnets.private.ids
  public_subnet_ids  = data.aws_subnets.public.ids

  # GitOps Configuration
  gitops_deployment_type = "single"
  
  # Addons Repository Configuration
  gitops_addons_org      = var.gitops_addons_org
  gitops_addons_repo     = var.gitops_addons_repo
  gitops_addons_revision = var.gitops_addons_revision
  gitops_addons_basepath = var.gitops_addons_basepath
  gitops_addons_path     = var.gitops_addons_path

  # Platform Repository Configuration
  gitops_platform_org      = var.gitops_platform_org
  gitops_platform_repo     = var.gitops_platform_repo
  gitops_platform_revision = var.gitops_platform_revision
  gitops_platform_basepath = var.gitops_platform_basepath
  gitops_platform_path     = var.gitops_platform_path

  # Workloads Repository Configuration
  gitops_workloads_org      = var.gitops_workloads_org
  gitops_workloads_repo     = var.gitops_workloads_repo
  gitops_workloads_revision = var.gitops_workloads_revision
  gitops_workloads_basepath = var.gitops_workloads_basepath
  gitops_workloads_path     = var.gitops_workloads_path

  # GitOps Authentication
  gitops_user     = var.gitops_user
  GITOPS_PASSWORD = var.gitops_password

  # Kubernetes Addons Configuration
  addons = {
    enable_aws_load_balancer_controller          = true
    enable_metrics_server                        = true
    enable_external_secrets                      = true
    enable_external_dns                          = true
    enable_secrets_store_csi_driver              = true
    enable_secrets_store_csi_driver_provider_aws = true
    enable_karpenter                             = var.enable_karpenter
    enable_cluster_autoscaler                    = var.enable_cluster_autoscaler
    enable_aws_node_termination_handler          = var.enable_aws_node_termination_handler
    enable_argo_workflows                        = true
    enable_istio                                 = var.enable_istio
    enable_grafana_loki                          = true
  }

  # Configuration Metadata
  conf_metadata = {
    enable_karpenter_conf        = var.enable_karpenter
    enable_system_customizations = true
    enable_kafka_ops             = false
    enable_tm_namespaces         = false
    enable_cni_custom            = var.vpc_cni_conf_mode == "custom_cfg"
    enable_istio_extensions      = var.enable_istio
    enable_custom_certificates   = var.enable_custom_certificates
  }

  # DNS Configuration
  external_dns_domain_filters = var.external_dns_domain_filters
  private_route53_zone_arn    = var.private_route53_zone_arn
  public_route53_zone_arn     = var.public_route53_zone_arn

  # VPC CNI Configuration
  vpc_cni_conf_mode = var.vpc_cni_conf_mode

  # Karpenter Configuration
  karpenter_discovery_tag = var.karpenter_discovery_tag

  # ArgoCD Configuration
  default_argoproj_name = var.default_argoproj_name
  gitops_repositories   = var.gitops_repositories

  # ArgoCD Ingress Configuration
  enable_argo_ingress = var.enable_argo_ingress
  argo_host_dns = var.enable_argo_ingress ? {
    domain_name            = var.argo_domain_name
    zone_id                = var.argo_zone_id
    aws_load_balancer_type = var.argo_load_balancer_type
    validation             = var.argo_validation_type
  } : null

  # SSO Configuration
  enable_sso    = var.enable_sso
  tenant_id     = var.tenant_id
  client_id     = var.client_id
  client_secret = var.client_secret

  # User Management Configuration
  user_management_config = {
    enabled                  = var.enable_user_management
    store_in_secrets_manager = true
    password_length          = 16
    password_special_chars   = "!#$%&*()-_=+[]{}<>:?"
    bcrypt_cost              = 10
    default_role             = "role:readonly"
  }

  # Custom Certificates
  internal_apps_domain_names = var.internal_apps_domain_names

  # Security Configuration
  core_cluster_apps_ingress_cidr = var.core_cluster_apps_ingress_cidr

  # Tags
  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Example     = "complete"
  })
}
```
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | terraform-aws-modules/acm/aws | ~> 4.0 |
| <a name="module_argocd_irsa"></a> [argocd\_irsa](#module\_argocd\_irsa) | aws-ia/eks-blueprints-addon/aws | 1.1.1 |
| <a name="module_aws_vpc_cni_ipv4_pod_identity"></a> [aws\_vpc\_cni\_ipv4\_pod\_identity](#module\_aws\_vpc\_cni\_ipv4\_pod\_identity) | terraform-aws-modules/eks-pod-identity/aws | 1.12.1 |
| <a name="module_core_ingress_sg"></a> [core\_ingress\_sg](#module\_core\_ingress\_sg) | terraform-aws-modules/security-group/aws | 5.3.0 |
| <a name="module_eks_blueprints_addons"></a> [eks\_blueprints\_addons](#module\_eks\_blueprints\_addons) | aws-ia/eks-blueprints-addons/aws | 1.21.1 |
| <a name="module_eks_native_addons"></a> [eks\_native\_addons](#module\_eks\_native\_addons) | ./modules/terraform-eks-addons | n/a |
| <a name="module_eks_vpc_cni_native_addons"></a> [eks\_vpc\_cni\_native\_addons](#module\_eks\_vpc\_cni\_native\_addons) | ./modules/terraform-eks-addons | n/a |
| <a name="module_hardening_gitops_bridge"></a> [hardening\_gitops\_bridge](#module\_hardening\_gitops\_bridge) | ./modules/terraform-helm-gitops-bridge-module | n/a |
| <a name="module_node_alb_traffic_rules"></a> [node\_alb\_traffic\_rules](#module\_node\_alb\_traffic\_rules) | terraform-aws-modules/security-group/aws | 5.3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.irsa_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_session_context.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_session_context) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## 📝 Inputs

This module accepts the following input variables. Variables are organized by category for easier navigation.

### Required Inputs

These inputs are required for the module to function properly:

| Name | Description | Type | Default | Required |
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#input\_cluster\_certificate\_authority\_data) | Base64 encoded certificate data required to communicate with the cluster | `string` | n/a | yes |
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | Endpoint for your Kubernetes API server | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | n/a | yes |
| <a name="input_cluster_platform_version"></a> [cluster\_platform\_version](#input\_cluster\_platform\_version) | Platform version for the cluster | `string` | n/a | yes |
| <a name="input_oidc_provider_arn"></a> [oidc\_provider\_arn](#input\_oidc\_provider\_arn) | The ARN of the OIDC Provider | `string` | n/a | yes |

### Optional Inputs

These inputs have default values and can be customized based on your requirements:
| <a name="input_GITOPS_PASSWORD"></a> [GITOPS\_PASSWORD](#input\_GITOPS\_PASSWORD) | GitOps password or token | `string` | `null` | no |
| <a name="input_addons"></a> [addons](#input\_addons) | Kubernetes addons | `any` | <pre>{<br/>  "enable_argo_workflows": true,<br/>  "enable_aws_load_balancer_controller": true,<br/>  "enable_aws_node_termination_handler": false,<br/>  "enable_cluster_autoscaler": false,<br/>  "enable_external_dns": true,<br/>  "enable_external_secrets": true,<br/>  "enable_grafana_loki": true,<br/>  "enable_istio": false,<br/>  "enable_karpenter": false,<br/>  "enable_metrics_server": true,<br/>  "enable_secrets_store_csi_driver": true,<br/>  "enable_secrets_store_csi_driver_provider_aws": true<br/>}</pre> | no |
| <a name="input_argo_host_dns"></a> [argo\_host\_dns](#input\_argo\_host\_dns) | Argo host for public access using ALB | <pre>object({<br/>    domain_name            = string<br/>    zone_id                = optional(string)<br/>    aws_load_balancer_type = optional(string)<br/>    validation = optional(string)<br/>  })</pre> | <pre>{<br/>  "aws_load_balancer_type": "internal",<br/>  "domain_name": "example.com",<br/>  "validation": "private",<br/>  "zone_id": "XXXXXXXXXXXXXX"<br/>}</pre> | no |
| <a name="input_argocd_iam_role_arn"></a> [argocd\_iam\_role\_arn](#input\_argocd\_iam\_role\_arn) | The ARN of the IAM role for Argo CD | `string` | `""` | no |
| <a name="input_client_id"></a> [client\_id](#input\_client\_id) | Client ID for Microsoft Entra ID SSO | `string` | `null` | no |
| <a name="input_client_secret"></a> [client\_secret](#input\_client\_secret) | Client Secret for Microsoft Entra ID SSO | `string` | `null` | no |
| <a name="input_cluster_autoscaler"></a> [cluster\_autoscaler](#input\_cluster\_autoscaler) | Cluster Autoscaler add-on configuration values | `any` | `{}` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes version for the cluster | `string` | `"1.30"` | no |
| <a name="input_conf_metadata"></a> [conf\_metadata](#input\_conf\_metadata) | Metadata for the configuration | <pre>object({<br/>    enable_karpenter_conf        = bool<br/>    enable_system_customizations = bool<br/>    enable_kafka_ops             = bool<br/>    enable_tm_namespaces         = bool<br/>    enable_cni_custom            = bool<br/>    enable_istio_extensions      = bool<br/>    enable_custom_certificates = bool<br/><br/>  })</pre> | <pre>{<br/>  "enable_cni_custom": false,<br/>  "enable_custom_certificates": false,<br/>  "enable_istio_extensions": false,<br/>  "enable_kafka_ops": false,<br/>  "enable_karpenter_conf": false,<br/>  "enable_system_customizations": false,<br/>  "enable_tm_namespaces": false<br/>}</pre> | no |
| <a name="input_core_cluster_apps_ingress_cidr"></a> [core\_cluster\_apps\_ingress\_cidr](#input\_core\_cluster\_apps\_ingress\_cidr) | Ingress CIDR for core cluster apps | `list(string)` | `[]` | no |
| <a name="input_default_argoproj_name"></a> [default\_argoproj\_name](#input\_default\_argoproj\_name) | Default argocd name | `string` | `"ldc-fc-contenerizacion-ti"` | no |
| <a name="input_eks_auto_scaling_groups_arns"></a> [eks\_auto\_scaling\_groups\_arns](#input\_eks\_auto\_scaling\_groups\_arns) | List of EKS Auto Scaling Groups ARNs | `list(string)` | `[]` | no |
| <a name="input_enable"></a> [enable](#input\_enable) | Enable or disable stack creation | `bool` | `true` | no |
| <a name="input_enable_argo_ingress"></a> [enable\_argo\_ingress](#input\_enable\_argo\_ingress) | Enable Argo CD ALB ingress | `bool` | `false` | no |
| <a name="input_enable_cluster_autoscaler"></a> [enable\_cluster\_autoscaler](#input\_enable\_cluster\_autoscaler) | Enable Cluster autoscaler add-on | `bool` | `false` | no |
| <a name="input_enable_sso"></a> [enable\_sso](#input\_enable\_sso) | Enable SSO integration with Entra ID | `bool` | `false` | no |
| <a name="input_external_dns_domain_filters"></a> [external\_dns\_domain\_filters](#input\_external\_dns\_domain\_filters) | External domains filters | `list(string)` | `[]` | no |
| <a name="input_gitops_addons_basepath"></a> [gitops\_addons\_basepath](#input\_gitops\_addons\_basepath) | Git repository base path for addons | `string` | `"gitops/addons/"` | no |
| <a name="input_gitops_addons_org"></a> [gitops\_addons\_org](#input\_gitops\_addons\_org) | Git repository org/user contains for addons | `string` | `"git@github.com:gitops-bridge-dev"` | no |
| <a name="input_gitops_addons_path"></a> [gitops\_addons\_path](#input\_gitops\_addons\_path) | Git repository path for addons | `string` | `"bootstrap/control-plane/addons"` | no |
| <a name="input_gitops_addons_repo"></a> [gitops\_addons\_repo](#input\_gitops\_addons\_repo) | Git repository contains for addons | `string` | `"gitops-bridge-argocd-control-plane-template"` | no |
| <a name="input_gitops_addons_revision"></a> [gitops\_addons\_revision](#input\_gitops\_addons\_revision) | Git repository revision/branch/ref for addons | `string` | `"HEAD"` | no |
| <a name="input_gitops_deployment_type"></a> [gitops\_deployment\_type](#input\_gitops\_deployment\_type) | GitOps type architecture deployment. hub-spoke, single | `string` | `"single"` | no |
| <a name="input_gitops_platform_basepath"></a> [gitops\_platform\_basepath](#input\_gitops\_platform\_basepath) | Git repository base path for platform | `string` | `""` | no |
| <a name="input_gitops_platform_org"></a> [gitops\_platform\_org](#input\_gitops\_platform\_org) | Git repository org/user contains for addons | `string` | `"git@github.com:gitops-bridge-dev"` | no |
| <a name="input_gitops_platform_path"></a> [gitops\_platform\_path](#input\_gitops\_platform\_path) | Git repository path for workload | `string` | `"bootstrap"` | no |
| <a name="input_gitops_platform_repo"></a> [gitops\_platform\_repo](#input\_gitops\_platform\_repo) | Git repository name for platform | `string` | `"gitops-platform"` | no |
| <a name="input_gitops_platform_revision"></a> [gitops\_platform\_revision](#input\_gitops\_platform\_revision) | Git repository revision/branch/ref for workload | `string` | `"HEAD"` | no |
| <a name="input_gitops_repositories"></a> [gitops\_repositories](#input\_gitops\_repositories) | List of allowed repositories in the Argo CD AppProject | `list(string)` | <pre>[<br/>  "https://aws.github.io/*",<br/>  "https://kubernetes-sigs.github.io/*",<br/>  "public.ecr.aws",<br/>  "https://kiali.org/helm-charts",<br/>  "https://charts.external-secrets.io",<br/>  "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts",<br/>  "https://istio-release.storage.googleapis.com/charts",<br/>  "https://argoproj.github.io/argo-helm",<br/>  "https://grafana.github.io/helm-charts",<br/>  "public.ecr.aws/dynatrace"<br/>]</pre> | no |
| <a name="input_gitops_user"></a> [gitops\_user](#input\_gitops\_user) | GitOps user | `string` | `"gitops"` | no |
| <a name="input_gitops_workloads_basepath"></a> [gitops\_workloads\_basepath](#input\_gitops\_workloads\_basepath) | Git repository base path for workload | `string` | `""` | no |
| <a name="input_gitops_workloads_org"></a> [gitops\_workloads\_org](#input\_gitops\_workloads\_org) | Git repository org/user contains for addons | `string` | `"git@github.com:gitops-bridge-dev"` | no |
| <a name="input_gitops_workloads_path"></a> [gitops\_workloads\_path](#input\_gitops\_workloads\_path) | Git repository path for workload | `string` | `""` | no |
| <a name="input_gitops_workloads_repo"></a> [gitops\_workloads\_repo](#input\_gitops\_workloads\_repo) | Git repository name for workload | `string` | `"gitops-apps"` | no |
| <a name="input_gitops_workloads_revision"></a> [gitops\_workloads\_revision](#input\_gitops\_workloads\_revision) | Git repository revision/branch/ref for workload | `string` | `"HEAD"` | no |
| <a name="input_internal_apps_domain_names"></a> [internal\_apps\_domain\_names](#input\_internal\_apps\_domain\_names) | Domain names for internal applications | `list(string)` | `[]` | no |
| <a name="input_karpenter_discovery_tag"></a> [karpenter\_discovery\_tag](#input\_karpenter\_discovery\_tag) | Karpenter tag for discovery resources | `string` | `"project"` | no |
| <a name="input_node_security_group"></a> [node\_security\_group](#input\_node\_security\_group) | Node security group ID | `string` | `""` | no |
| <a name="input_private_route53_zone_arn"></a> [private\_route53\_zone\_arn](#input\_private\_route53\_zone\_arn) | Private Route53 zone ARN | `list(string)` | `[]` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | List of private subnet IDs | `list(string)` | `[]` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project Name | `string` | `""` | no |
| <a name="input_public_route53_zone_arn"></a> [public\_route53\_zone\_arn](#input\_public\_route53\_zone\_arn) | Public Route53 zone ARN | `list(string)` | `[]` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | List of public subnet IDs | `list(string)` | `[]` | no |
| <a name="input_subnet_details"></a> [subnet\_details](#input\_subnet\_details) | Map of subnet details | <pre>map(list(object({<br/>    cidr             = string<br/>    subnetId         = string<br/>    availabilityZone = string<br/><br/>  })))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Tenant ID for Microsoft Entra ID SSO | `string` | `null` | no |
| <a name="input_user_management_config"></a> [user\_management\_config](#input\_user\_management\_config) | Configuration for user management features | <pre>object({<br/>    enabled                  = bool<br/>    store_in_secrets_manager = bool<br/>    password_length          = number<br/>    password_special_chars   = string<br/>    bcrypt_cost              = number<br/>    default_role             = string<br/>  })</pre> | <pre>{<br/>  "bcrypt_cost": 10,<br/>  "default_role": "role:readonly",<br/>  "enabled": false,<br/>  "password_length": 16,<br/>  "password_special_chars": "!#$%&*()-_=+[]{}<>:?",<br/>  "store_in_secrets_manager": true<br/>}</pre> | no |
| <a name="input_vpc_cni_conf_mode"></a> [vpc\_cni\_conf\_mode](#input\_vpc\_cni\_conf\_mode) | VPC CNI mode, use custom\_cfg for secondary subnets and default\_cfg for delegation prefix | `string` | `"default_cfg"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC Id | `string` | `""` | no |

### Input Validation and Examples

#### Required Inputs Example
```hcl
module "gitops_bridge" {
  source = "path/to/terraform-hardening-gitops-bridge"

  # Required inputs - must be provided
  cluster_name                         = "my-eks-cluster"
  cluster_endpoint                     = "https://xxxxx.gr7.us-west-2.eks.amazonaws.com"
  cluster_certificate_authority_data   = "LS0tLS1CRUdJTi..."
  cluster_platform_version             = "eks.1"
  oidc_provider_arn                    = "arn:aws:iam::123456789012:oidc-provider/..."
}
```

#### Common Configuration Patterns
```hcl
# Basic GitOps setup
gitops_addons_org  = "git@github.com:my-org"
gitops_addons_repo = "my-addons-repo"

# Enable essential addons
addons = {
  enable_aws_load_balancer_controller = true
  enable_metrics_server               = true
  enable_external_secrets             = true
  enable_external_dns                 = true
}

# SSO configuration
enable_sso    = true
tenant_id     = "your-tenant-id"
client_id     = "your-client-id"
client_secret = "your-client-secret"
```

#### Input Validation Rules

- **cluster_name**: Must be a valid EKS cluster name (1-100 characters, alphanumeric and hyphens)
- **cluster_endpoint**: Must be a valid HTTPS URL
- **oidc_provider_arn**: Must be a valid AWS IAM OIDC provider ARN
- **vpc_id**: Must be a valid VPC ID if provided
- **subnet_ids**: Must be valid subnet IDs within the specified VPC

## 📤 Outputs

The module provides the following outputs that can be used by other Terraform configurations or for reference:

| Name | Description | Type | Sensitive |
|------|-------------|------|-----------|
| <a name="output_addons"></a> [addons](#output\_addons) | Map of enabled EKS addons and their configurations | `map(any)` | No |

### Output Usage Examples

```hcl
# Access the addons output
output "enabled_addons" {
  description = "List of enabled addons"
  value       = module.gitops_bridge.addons
}

# Use outputs in other resources
resource "aws_ssm_parameter" "addon_status" {
  name  = "/eks/${var.cluster_name}/addons"
  type  = "String"
  value = jsonencode(module.gitops_bridge.addons)
}
```

### Additional Information Available

While not exposed as outputs, the module creates several resources that can be referenced:

- **ArgoCD Applications**: Available in the `argocd` namespace
- **Security Groups**: Created for ingress and load balancer traffic
- **IAM Roles**: Service account roles for various addons
- **Route53 Records**: DNS records for ingress endpoints (if configured)

```bash
# Access ArgoCD applications
kubectl get applications -n argocd

# View created security groups
aws ec2 describe-security-groups --filters "Name=tag:kubernetes.io/cluster/${cluster_name},Values=owned"

# Check addon status
kubectl get pods -n kube-system
```

<!-- END_TF_DOCS -->

## 📋 FAQ

### Q: Can I use this module with existing EKS clusters?
A: Yes, this module is designed to work with existing EKS clusters. You just need to provide the cluster details.

### Q: How do I enable SSO with Microsoft Entra ID?
A: Set `enable_sso = true` and provide your `tenant_id`, `client_id`, and `client_secret`.

### Q: Can I customize the ArgoCD configuration?
A: Yes, you can customize ArgoCD through the module's configuration options and Helm values.

### Q: How do I add custom addons?
A: You can extend the addons configuration or add custom applications through your GitOps repositories.

### Q: Is this module production-ready?
A: Yes, this module implements enterprise-grade security and best practices suitable for production environments.

### Q: How do I backup ArgoCD configurations?
A: ArgoCD configurations are stored in your Git repositories, providing built-in backup and version control.

### Q: Can I use this with multiple AWS accounts?
A: Yes, you can deploy this module across multiple AWS accounts with proper cross-account IAM roles.

### Q: How do I monitor the GitOps pipeline?
A: Use ArgoCD's built-in UI and integrate with your monitoring stack using the provided observability addons.