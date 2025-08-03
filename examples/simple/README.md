# Simple Example - Terraform Hardening GitOps Bridge

This example demonstrates a minimal deployment of the Terraform Hardening GitOps Bridge module with essential features only.

## Overview

This simple example includes:
- Basic ArgoCD deployment
- Essential Kubernetes addons (AWS Load Balancer Controller, Metrics Server, External Secrets)
- Minimal configuration for quick setup
- Default GitOps repository settings

## What's Included

### Enabled Addons
- ✅ AWS Load Balancer Controller
- ✅ Metrics Server
- ✅ External Secrets
- ✅ Secrets Store CSI Driver
- ✅ Secrets Store CSI Driver Provider AWS
- ✅ Argo Workflows

### Disabled Features (for simplicity)
- ❌ External DNS
- ❌ Karpenter
- ❌ Cluster Autoscaler
- ❌ Istio Service Mesh
- ❌ Grafana Loki
- ❌ ArgoCD Ingress
- ❌ SSO Integration
- ❌ Custom Certificates

## Prerequisites

1. **Existing EKS Cluster**: You need an existing EKS cluster
2. **AWS CLI**: Configured with appropriate permissions
3. **Terraform**: Version >= 1.0
4. **kubectl**: For cluster access

## Quick Start

1. **Copy the example**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit terraform.tfvars**:
   ```hcl
   cluster_name = "your-eks-cluster-name"
   vpc_id       = "vpc-xxxxxxxxx"
   gitops_password = "your-secure-token"
   ```

3. **Deploy**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `cluster_name` | Name of your existing EKS cluster | `"my-eks-cluster"` |
| `vpc_id` | VPC ID where your cluster is deployed | `"vpc-0123456789abcdef0"` |
| `gitops_password` | Secure token for GitOps authentication | `"your-secure-token"` |

## Post-Deployment

### Access ArgoCD

1. **Port-forward to ArgoCD**:
   ```bash
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   ```

2. **Open ArgoCD UI**:
   ```bash
   open https://localhost:8080
   ```

3. **Get admin password**:
   ```bash
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
   ```

### Verify Installation

```bash
# Check ArgoCD pods
kubectl get pods -n argocd

# Check enabled addons
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
kubectl get pods -n external-secrets
```

## Next Steps

Once you have the simple example working, you can:

1. **Enable more addons** by modifying the `addons` configuration
2. **Add External DNS** by providing Route53 zone ARNs
3. **Enable ArgoCD Ingress** for public access
4. **Explore the complete example** for advanced features

## Cleanup

```bash
terraform destroy
```

This will remove the GitOps bridge components but preserve your EKS cluster.
