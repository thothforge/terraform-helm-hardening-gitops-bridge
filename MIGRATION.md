# Migration Guide

This guide provides step-by-step instructions for migrating to the Terraform Hardening GitOps Bridge Module from various existing setups.

## 🔄 Migration Scenarios

### From Legacy GitOps Solutions

#### Pre-migration Checklist
- [ ] Backup existing configurations
- [ ] Document current GitOps workflows
- [ ] Identify custom applications and configurations
- [ ] Plan downtime windows
- [ ] Prepare rollback procedures

#### Migration Steps

1. **Prepare New Repository Structure**
```bash
# Create new GitOps repository structure
mkdir -p gitops-repo/{addons,platform,workloads}
```

2. **Migrate Existing Applications**
```bash
# Export existing ArgoCD applications
kubectl get applications -n argocd -o yaml > existing-apps.yaml

# Convert to new structure
# (Manual process based on your current setup)
```

3. **Deploy GitOps Bridge**
```hcl
module "gitops_bridge" {
  source = "path/to/terraform-hardening-gitops-bridge"
  
  # Migration-specific configuration
  gitops_deployment_type = "single"
  
  # Preserve existing settings
  cluster_name = var.existing_cluster_name
  # ... other configurations
}
```

4. **Validate Migration**
```bash
# Check all applications are synced
kubectl get applications -n argocd

# Verify addon functionality
kubectl get pods --all-namespaces
```

### From Manual Kubernetes Management

#### Assessment Phase
1. **Inventory Current Resources**
```bash
# List all namespaces
kubectl get namespaces

# Export current configurations
kubectl get all --all-namespaces -o yaml > current-state.yaml
```

2. **Identify GitOps Candidates**
- Applications suitable for GitOps management
- Static configurations vs. dynamic workloads
- Security and compliance requirements

#### Implementation Phase
1. **Start with Non-Critical Workloads**
2. **Gradually Migrate Core Services**
3. **Implement Monitoring and Alerting**
4. **Train Team on GitOps Workflows**

### From Other ArgoCD Installations

#### Pre-migration Assessment
```bash
# Export current ArgoCD configuration
kubectl get configmap argocd-cm -n argocd -o yaml > argocd-config-backup.yaml
kubectl get secret argocd-secret -n argocd -o yaml > argocd-secret-backup.yaml

# List current applications
kubectl get applications -n argocd -o yaml > applications-backup.yaml

# Export RBAC configuration
kubectl get configmap argocd-rbac-cm -n argocd -o yaml > argocd-rbac-backup.yaml
```

#### Migration Process

1. **Backup Current State**
```bash
# Create comprehensive backup
kubectl create namespace argocd-backup
kubectl get all -n argocd -o yaml > argocd-full-backup.yaml
```

2. **Prepare New Configuration**
```hcl
module "gitops_bridge" {
  source = "path/to/terraform-hardening-gitops-bridge"
  
  # Preserve existing repository configurations
  gitops_addons_org  = "your-existing-org"
  gitops_addons_repo = "your-existing-repo"
  
  # Migrate SSO settings if applicable
  enable_sso    = true
  tenant_id     = var.existing_tenant_id
  client_id     = var.existing_client_id
  client_secret = var.existing_client_secret
  
  # Other configurations...
}
```

3. **Gradual Cutover**
```bash
# Scale down existing ArgoCD (if replacing)
kubectl scale deployment argocd-server --replicas=0 -n argocd

# Deploy new GitOps bridge
terraform apply

# Verify new installation
kubectl get pods -n argocd
```

4. **Restore Applications**
```bash
# Apply backed up applications (after reviewing and updating)
kubectl apply -f applications-backup.yaml
```

## 🔧 Migration Tools and Scripts

### Repository Structure Converter
```bash
#!/bin/bash
# migrate-repo-structure.sh

OLD_REPO_PATH="$1"
NEW_REPO_PATH="$2"

# Create new structure
mkdir -p "$NEW_REPO_PATH"/{addons,platform,workloads}

# Migrate addons
if [ -d "$OLD_REPO_PATH/charts" ]; then
    cp -r "$OLD_REPO_PATH/charts"/* "$NEW_REPO_PATH/addons/"
fi

# Migrate platform configurations
if [ -d "$OLD_REPO_PATH/platform" ]; then
    cp -r "$OLD_REPO_PATH/platform"/* "$NEW_REPO_PATH/platform/"
fi

# Migrate applications
if [ -d "$OLD_REPO_PATH/apps" ]; then
    cp -r "$OLD_REPO_PATH/apps"/* "$NEW_REPO_PATH/workloads/"
fi

echo "Migration completed. Please review and adjust the new structure."
```

### Configuration Converter
```python
#!/usr/bin/env python3
# convert-argocd-config.py

import yaml
import sys

def convert_application(old_app):
    """Convert old ArgoCD application format to new structure"""
    new_app = {
        'apiVersion': 'argoproj.io/v1alpha1',
        'kind': 'Application',
        'metadata': {
            'name': old_app['metadata']['name'],
            'namespace': 'argocd'
        },
        'spec': {
            'project': 'default',
            'source': old_app['spec']['source'],
            'destination': old_app['spec']['destination'],
            'syncPolicy': {
                'automated': {
                    'prune': True,
                    'selfHeal': True
                }
            }
        }
    }
    return new_app

if __name__ == "__main__":
    with open(sys.argv[1], 'r') as f:
        old_config = yaml.safe_load(f)
    
    new_config = convert_application(old_config)
    
    with open(sys.argv[2], 'w') as f:
        yaml.dump(new_config, f, default_flow_style=False)
```

## 📋 Migration Checklist

### Pre-Migration
- [ ] Document current architecture
- [ ] Backup all configurations
- [ ] Test migration in non-production environment
- [ ] Prepare rollback procedures
- [ ] Schedule maintenance window
- [ ] Notify stakeholders

### During Migration
- [ ] Execute backup procedures
- [ ] Deploy new GitOps bridge
- [ ] Migrate applications gradually
- [ ] Verify each component
- [ ] Monitor system health
- [ ] Document any issues

### Post-Migration
- [ ] Validate all applications are running
- [ ] Test GitOps workflows
- [ ] Verify monitoring and alerting
- [ ] Update documentation
- [ ] Train team on new processes
- [ ] Clean up old resources

## 🚨 Rollback Procedures

### Emergency Rollback
```bash
# Quick rollback to previous ArgoCD installation
kubectl apply -f argocd-full-backup.yaml

# Scale up previous installation
kubectl scale deployment argocd-server --replicas=1 -n argocd

# Verify rollback
kubectl get pods -n argocd
```

### Gradual Rollback
1. **Stop new deployments**
2. **Restore critical applications first**
3. **Gradually restore remaining services**
4. **Verify system stability**

## 🔍 Migration Validation

### Functional Testing
```bash
# Test ArgoCD UI access
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Verify application sync
kubectl get applications -n argocd

# Test GitOps workflow
git commit -m "test: migration validation"
git push origin main
```

### Performance Testing
```bash
# Monitor resource usage
kubectl top pods -n argocd

# Check application sync times
kubectl describe application <app-name> -n argocd
```

## 📚 Migration Best Practices

### Planning
1. **Start Small**: Begin with non-critical applications
2. **Test Thoroughly**: Use staging environments
3. **Document Everything**: Keep detailed migration logs
4. **Plan for Rollback**: Always have a backup plan

### Execution
1. **Gradual Migration**: Don't migrate everything at once
2. **Monitor Closely**: Watch for issues during migration
3. **Validate Continuously**: Test each step
4. **Communicate**: Keep stakeholders informed

### Post-Migration
1. **Monitor Performance**: Watch for degradation
2. **Gather Feedback**: Get user input
3. **Optimize**: Fine-tune configurations
4. **Document Lessons**: Record what worked and what didn't

## 🔗 Related Documentation

- [Troubleshooting Guide](./TROUBLESHOOTING.md) - For resolving migration issues
- [Upgrade Guide](./UPGRADE.md) - For version upgrades
- [Main README](./README.md) - Complete module documentation
- [Examples](./examples/) - Working configuration examples
