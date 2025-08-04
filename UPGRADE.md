# Upgrade Guide

This guide provides comprehensive instructions for upgrading the Terraform Hardening GitOps Bridge Module to newer versions.

## 📋 Version Compatibility

### Version Matrix

| Module Version | Terraform | AWS Provider | Kubernetes | ArgoCD |
|----------------|-----------|--------------|------------|--------|
| 2.x.x          | >= 1.5    | >= 5.40      | >= 1.29    | >= 2.10|
| 1.x.x          | >= 1.0    | >= 5.0       | >= 1.28    | >= 2.8 |

### Breaking Changes by Version

#### Version 2.0.0
- **ArgoCD Helm Chart**: Updated to v6.x.x
- **AWS Provider**: Minimum version increased to 5.40
- **Kubernetes Provider**: Minimum version increased to 2.25
- **Deprecated Variables**: Removed legacy configuration options

#### Version 1.5.0
- **Karpenter**: Updated to v0.35.x
- **External DNS**: Updated configuration format
- **Security Groups**: Enhanced security group management

## 🚀 Upgrade Process

### Pre-Upgrade Checklist

- [ ] Review changelog for breaking changes
- [ ] Backup current Terraform state
- [ ] Test upgrade in non-production environment
- [ ] Verify provider version compatibility
- [ ] Plan maintenance window
- [ ] Prepare rollback procedures

### Step-by-Step Upgrade

#### 1. Backup Current State
```bash
# Backup Terraform state
terraform state pull > terraform-state-backup.json

# Backup ArgoCD applications
kubectl get applications -n argocd -o yaml > argocd-apps-backup.yaml

# Backup important configurations
kubectl get configmaps -n argocd -o yaml > argocd-configmaps-backup.yaml
kubectl get secrets -n argocd -o yaml > argocd-secrets-backup.yaml
```

#### 2. Update Module Version
```hcl
module "gitops_bridge" {
  source = "path/to/terraform-hardening-gitops-bridge"
  # Update to new version
  # source = "git::https://github.com/your-org/terraform-hardening-gitops-bridge.git?ref=v2.0.0"
  
  # Review and update configuration for new version
  # ... existing configuration
}
```

#### 3. Review Configuration Changes
```bash
# Check for deprecated variables
terraform validate

# Review planned changes
terraform plan -out=upgrade.tfplan
```

#### 4. Apply Upgrade
```bash
# Apply the upgrade
terraform apply upgrade.tfplan

# Monitor the upgrade process
kubectl get pods -n argocd -w
```

#### 5. Validate Upgrade
```bash
# Check ArgoCD status
kubectl get pods -n argocd
kubectl get applications -n argocd

# Verify addon functionality
kubectl get pods -n kube-system

# Test ArgoCD UI access
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

## 🔄 Version-Specific Upgrade Instructions

### Upgrading to v2.0.0

#### Configuration Changes Required

1. **Update Provider Versions**
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.40"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.25"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12"
    }
  }
}
```

2. **Update ArgoCD Configuration**
```hcl
# Old format (deprecated)
argocd_config = {
  server_insecure = true
}

# New format
argo_host_dns = {
  domain_name            = "argocd.example.com"
  zone_id                = "Z123456789"
  aws_load_balancer_type = "internet-facing"
  validation             = "dns"
}
```

3. **Update Addon Configuration**
```hcl
# Enhanced addon configuration
addons = {
  enable_aws_load_balancer_controller          = true
  enable_metrics_server                        = true
  enable_external_secrets                      = true
  enable_external_dns                          = true
  enable_secrets_store_csi_driver              = true
  enable_secrets_store_csi_driver_provider_aws = true
  enable_karpenter                             = true
  enable_argo_workflows                        = true
  enable_grafana_loki                          = true
  # New in v2.0.0
  enable_istio                                 = false
  enable_prometheus                            = false
}
```

#### Migration Steps for v2.0.0

1. **Update Karpenter Configuration**
```bash
# Remove old Karpenter CRDs if upgrading from v0.31.x or earlier
kubectl delete crd awsnodetemplates.karpenter.k8s.aws
kubectl delete crd provisioners.karpenter.sh

# The module will install new CRDs automatically
```

2. **Update External DNS Configuration**
```hcl
# Old format
external_dns_config = {
  domain_filters = ["example.com"]
}

# New format
external_dns_domain_filters = ["example.com"]
private_route53_zone_arn    = ["arn:aws:route53:::hostedzone/Z123456789"]
public_route53_zone_arn     = ["arn:aws:route53:::hostedzone/Z987654321"]
```

### Upgrading to v1.5.0

#### Key Changes
- Updated Karpenter to v0.35.x
- Enhanced security group management
- Improved RBAC configurations

#### Required Actions
```bash
# Update Karpenter node pools
kubectl get nodepools -o yaml > nodepools-backup.yaml
kubectl get ec2nodeclasses -o yaml > ec2nodeclasses-backup.yaml

# Apply upgrade
terraform apply

# Verify Karpenter functionality
kubectl logs -n karpenter deployment/karpenter
```

## 🔧 Troubleshooting Upgrades

### Common Upgrade Issues

#### ArgoCD Server Not Starting
```bash
# Check ArgoCD server logs
kubectl logs -n argocd deployment/argocd-server

# Common fix: Clear ArgoCD cache
kubectl delete configmap argocd-cm -n argocd
terraform apply
```

#### Karpenter Issues After Upgrade
```bash
# Check Karpenter logs
kubectl logs -n karpenter deployment/karpenter

# Restart Karpenter if needed
kubectl rollout restart deployment/karpenter -n karpenter
```

#### External DNS Not Working
```bash
# Check External DNS logs
kubectl logs -n kube-system deployment/external-dns

# Verify Route53 permissions
aws sts get-caller-identity
aws route53 list-hosted-zones
```

### Rollback Procedures

#### Quick Rollback
```bash
# Restore from backup
terraform state push terraform-state-backup.json

# Revert to previous module version
# Update module source in your configuration
terraform init -upgrade
terraform apply
```

#### Gradual Rollback
1. **Identify problematic components**
2. **Rollback specific resources**
3. **Verify system stability**
4. **Plan proper upgrade path**

## 📊 Post-Upgrade Validation

### Functional Testing
```bash
# Test ArgoCD functionality
kubectl get applications -n argocd
kubectl describe application <app-name> -n argocd

# Test addon functionality
kubectl get pods -n kube-system
kubectl get pods -n argocd

# Test DNS resolution
nslookup argocd.example.com

# Test load balancer
kubectl get svc -n argocd
```

### Performance Testing
```bash
# Monitor resource usage
kubectl top pods -n argocd
kubectl top pods -n kube-system

# Check application sync times
kubectl get applications -n argocd -o wide
```

### Security Validation
```bash
# Verify RBAC configurations
kubectl auth can-i --list --as=system:serviceaccount:argocd:argocd-server

# Check security groups
aws ec2 describe-security-groups --filters "Name=group-name,Values=*${cluster_name}*"

# Verify certificate status
kubectl get certificates --all-namespaces
```

## 📋 Upgrade Best Practices

### Planning
1. **Read Release Notes**: Always review changelog and breaking changes
2. **Test in Staging**: Never upgrade production directly
3. **Plan Downtime**: Schedule appropriate maintenance windows
4. **Prepare Rollback**: Have a tested rollback plan

### Execution
1. **Backup Everything**: State, configurations, and data
2. **Upgrade Gradually**: Don't upgrade everything at once
3. **Monitor Closely**: Watch for issues during upgrade
4. **Validate Thoroughly**: Test all functionality

### Post-Upgrade
1. **Monitor Performance**: Watch for degradation
2. **Update Documentation**: Keep docs current
3. **Train Team**: Ensure team knows about changes
4. **Plan Next Upgrade**: Stay current with releases

## 🔄 Automated Upgrade Strategies

### CI/CD Pipeline Integration
```yaml
# .github/workflows/upgrade.yml
name: Module Upgrade
on:
  schedule:
    - cron: '0 2 * * 1'  # Weekly on Monday at 2 AM
  workflow_dispatch:

jobs:
  upgrade:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
      - name: Backup State
        run: terraform state pull > backup.json
      - name: Plan Upgrade
        run: terraform plan -out=upgrade.tfplan
      - name: Apply Upgrade
        run: terraform apply upgrade.tfplan
      - name: Validate
        run: |
          kubectl get pods -n argocd
          kubectl get applications -n argocd
```

### Monitoring and Alerting
```yaml
# monitoring/upgrade-alerts.yml
groups:
- name: upgrade-monitoring
  rules:
  - alert: UpgradeInProgress
    expr: up{job="terraform"} == 0
    for: 5m
    labels:
      severity: info
    annotations:
      summary: "Module upgrade in progress"
  
  - alert: UpgradeFailed
    expr: terraform_state_serial != terraform_state_serial offset 1h
    for: 10m
    labels:
      severity: critical
    annotations:
      summary: "Module upgrade may have failed"
```

## 🔗 Related Documentation

- [Troubleshooting Guide](./TROUBLESHOOTING.md) - For resolving upgrade issues
- [Migration Guide](./MIGRATION.md) - For migrating from other solutions
- [Main README](./README.md) - Complete module documentation
- [Changelog](./CHANGELOG.md) - Detailed version history
