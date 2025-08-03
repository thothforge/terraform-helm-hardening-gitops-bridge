# Terraform Hardening GitOps Bridge - Examples

This directory contains examples demonstrating different ways to use the Terraform Hardening GitOps Bridge module.

## Available Examples

### 🚀 [Simple Example](./simple/)
A minimal configuration perfect for getting started quickly.

**Features:**
- Essential Kubernetes addons only
- Basic ArgoCD deployment
- Minimal configuration required
- Default GitOps repository settings

**Best for:**
- First-time users
- Development environments
- Quick proof-of-concept deployments

### 🏗️ [Complete Example](./complete/)
A comprehensive configuration showcasing all module features.

**Features:**
- All available Kubernetes addons
- ArgoCD with ingress and SSO integration
- External DNS with Route53 integration
- Custom certificates and security configurations
- Multiple GitOps repository configurations
- Advanced networking and VPC CNI options

**Best for:**
- Production environments
- Full-featured GitOps implementations
- Learning all module capabilities

## Quick Comparison

| Feature | Simple | Complete |
|---------|--------|----------|
| AWS Load Balancer Controller | ✅ | ✅ |
| Metrics Server | ✅ | ✅ |
| External Secrets | ✅ | ✅ |
| External DNS | ❌ | ✅ |
| Karpenter | ❌ | ✅ (optional) |
| Istio Service Mesh | ❌ | ✅ (optional) |
| ArgoCD Ingress | ❌ | ✅ (optional) |
| SSO Integration | ❌ | ✅ (optional) |
| Custom Certificates | ❌ | ✅ (optional) |
| User Management | ❌ | ✅ (optional) |

## Prerequisites

All examples require:

1. **Existing EKS Cluster**: The module works with existing EKS clusters
2. **AWS CLI**: Configured with appropriate permissions
3. **Terraform**: Version >= 1.0
4. **kubectl**: For cluster access and verification

### AWS Permissions Required

Your AWS credentials need permissions for:
- EKS cluster access and management
- IAM role and policy creation/management
- EC2 (security groups, networking)
- Route53 (if using External DNS)
- Secrets Manager (if using user management)

## Getting Started

1. **Choose an example** based on your needs:
   - New to GitOps? Start with [Simple](./simple/)
   - Need full features? Use [Complete](./complete/)

2. **Navigate to the example directory**:
   ```bash
   cd simple/  # or complete/
   ```

3. **Follow the example's README** for specific instructions

## Common Configuration

### Required Variables (All Examples)

```hcl
# Your existing EKS cluster name
cluster_name = "my-eks-cluster"

# VPC ID where your cluster is deployed
vpc_id = "vpc-0123456789abcdef0"

# Secure token for GitOps authentication
gitops_password = "your-secure-token"
```

### GitOps Repository Structure

The module expects GitOps repositories with the following structure:

```
gitops-addons/
├── bootstrap/
│   └── control-plane/
│       └── addons/
│           ├── aws-load-balancer-controller/
│           ├── external-dns/
│           └── ...

gitops-platform/
├── bootstrap/
│   ├── cluster-config/
│   └── addons/

gitops-workloads/
├── apps/
│   ├── app1/
│   └── app2/
```

## Post-Deployment Verification

After deploying any example:

### 1. Check ArgoCD
```bash
# Verify ArgoCD pods are running
kubectl get pods -n argocd

# Access ArgoCD UI (port-forward method)
kubectl port-forward svc/argocd-server -n argocd 8080:443
open https://localhost:8080

# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### 2. Verify Addons
```bash
# Check AWS Load Balancer Controller
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller

# Check External Secrets (if enabled)
kubectl get pods -n external-secrets

# Check all addon namespaces
kubectl get namespaces | grep -E "(external|karpenter|istio)"
```

### 3. Check ArgoCD Applications
```bash
# List all ArgoCD applications
kubectl get applications -n argocd

# Check application sync status
kubectl get applications -n argocd -o wide
```

## Troubleshooting

### Common Issues

1. **OIDC Provider Not Found**
   - Ensure your EKS cluster has an OIDC provider
   - Check the OIDC provider ARN format

2. **GitOps Repository Access**
   - Verify SSH keys are configured for Git access
   - Check repository URLs and permissions

3. **Addon Deployment Failures**
   - Check ArgoCD application status: `kubectl describe application <app-name> -n argocd`
   - Review ArgoCD server logs: `kubectl logs -n argocd deployment/argocd-server`

4. **Network Connectivity**
   - Verify VPC and subnet configurations
   - Check security group rules

### Debug Commands

```bash
# Check cluster connectivity
kubectl cluster-info

# Verify node status
kubectl get nodes

# Check all pods across namespaces
kubectl get pods --all-namespaces

# ArgoCD application details
kubectl describe application -n argocd <application-name>

# Check events for issues
kubectl get events --sort-by=.metadata.creationTimestamp
```

## Migration Between Examples

### From Simple to Complete

1. **Backup current state**:
   ```bash
   terraform state pull > backup.tfstate
   ```

2. **Copy complete example configuration**
3. **Import existing resources** (if needed)
4. **Plan and apply changes**:
   ```bash
   terraform plan
   terraform apply
   ```

## Security Best Practices

- Store sensitive values in environment variables or secure vaults
- Use least-privilege IAM policies
- Enable EKS audit logging
- Regularly update addon versions
- Monitor ArgoCD access and deployments
- Use private Git repositories for sensitive configurations

## Support

For issues and questions:
1. Check the specific example's README
2. Review the main module documentation
3. Verify AWS permissions and cluster connectivity
4. Check Terraform plan output for validation errors

## Contributing

When adding new examples:
1. Follow the existing directory structure
2. Include comprehensive README documentation
3. Provide terraform.tfvars.example files
4. Test with different cluster configurations
5. Document any special requirements or limitations
