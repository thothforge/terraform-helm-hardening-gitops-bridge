# Complete Example - Terraform Hardening GitOps Bridge

This example demonstrates a complete deployment of the Terraform Hardening GitOps Bridge module with all major features enabled.

## Overview

This example shows how to:
- Deploy GitOps bridge on an existing EKS cluster
- Configure multiple GitOps repositories (addons, platform, workloads)
- Enable various Kubernetes addons (AWS Load Balancer Controller, External DNS, Karpenter, etc.)
- Set up ArgoCD with optional ingress and SSO integration
- Configure DNS management and custom certificates
- Implement security best practices

## Prerequisites

Before running this example, ensure you have:

1. **Existing EKS Cluster**: This module requires an existing EKS cluster
2. **AWS CLI**: Configured with appropriate permissions
3. **Terraform**: Version >= 1.0
4. **kubectl**: For cluster access verification
5. **Git Repositories**: Set up your GitOps repositories (addons, platform, workloads)

### Required AWS Permissions

Your AWS credentials need permissions for:
- EKS cluster access
- IAM role and policy management
- Route53 (if using External DNS)
- EC2 (for security groups and networking)
- Secrets Manager (if using user management features)

## Usage

1. **Clone and Navigate**:
   ```bash
   git clone <repository-url>
   cd examples/complete
   ```

2. **Copy and Customize Variables**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
   
   Edit `terraform.tfvars` with your specific values:
   - `cluster_name`: Your existing EKS cluster name
   - `vpc_id`: VPC ID where your EKS cluster is deployed
   - GitOps repository configurations
   - DNS zones and domain configurations

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```

4. **Plan the Deployment**:
   ```bash
   terraform plan
   ```

5. **Apply the Configuration**:
   ```bash
   terraform apply
   ```

## Configuration Options

### Core Configuration

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `cluster_name` | Name of existing EKS cluster | Yes | - |
| `vpc_id` | VPC ID where cluster is deployed | Yes | - |
| `project_name` | Project name for resource naming | No | `"gitops-example"` |

### GitOps Repositories

Configure three types of repositories:

1. **Addons Repository**: Contains Kubernetes addons configurations
2. **Platform Repository**: Contains platform-level configurations
3. **Workloads Repository**: Contains application workloads

### Kubernetes Addons

The following addons can be enabled/disabled:

- **AWS Load Balancer Controller**: Always enabled
- **Metrics Server**: Always enabled
- **External Secrets**: Always enabled
- **External DNS**: Always enabled
- **Secrets Store CSI Driver**: Always enabled
- **Karpenter**: Optional (set `enable_karpenter = true`)
- **Cluster Autoscaler**: Optional (set `enable_cluster_autoscaler = true`)
- **AWS Node Termination Handler**: Optional
- **Istio Service Mesh**: Optional (set `enable_istio = true`)
- **Argo Workflows**: Always enabled
- **Grafana Loki**: Always enabled

### ArgoCD Configuration

#### Basic ArgoCD
ArgoCD is deployed by default in the `argocd` namespace.

#### ArgoCD Ingress (Optional)
Enable public access to ArgoCD:
```hcl
enable_argo_ingress = true
argo_domain_name = "argocd.example.com"
argo_zone_id = "Z1234567890ABC"
```

#### SSO Integration (Optional)
Enable Microsoft Entra ID SSO:
```hcl
enable_sso = true
tenant_id = "your-tenant-id"
client_id = "your-client-id"
client_secret = "your-client-secret"
```

### DNS Management

Configure External DNS with Route53:
```hcl
external_dns_domain_filters = ["example.com"]
private_route53_zone_arn = ["arn:aws:route53:::hostedzone/Z1234567890ABC"]
public_route53_zone_arn = ["arn:aws:route53:::hostedzone/Z0987654321XYZ"]
```

### VPC CNI Configuration

Choose between two modes:
- `default_cfg`: Standard configuration with prefix delegation
- `custom_cfg`: Custom configuration for secondary subnets

### Security Features

- **Custom Certificates**: Enable for internal applications
- **User Management**: Built-in user management with Secrets Manager integration
- **Network Security**: Configure ingress CIDR blocks for core applications

## Outputs

After successful deployment, the following outputs are available:

- `addons`: EKS addons configuration and status
- `cluster_*`: Cluster information (name, endpoint, version)
- `vpc_id` and subnet information
- `gitops_*`: GitOps repository configurations
- `enabled_addons`: List of enabled Kubernetes addons

## Post-Deployment

### Verify ArgoCD Installation

1. **Check ArgoCD Pods**:
   ```bash
   kubectl get pods -n argocd
   ```

2. **Access ArgoCD UI** (if ingress enabled):
   ```bash
   # Via ingress
   open https://your-argocd-domain.com
   
   # Via port-forward (if no ingress)
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   open https://localhost:8080
   ```

3. **Get ArgoCD Admin Password**:
   ```bash
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
   ```

### Verify Addons

Check that enabled addons are running:
```bash
# AWS Load Balancer Controller
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller

# External DNS
kubectl get pods -n external-dns

# Karpenter (if enabled)
kubectl get pods -n karpenter

# External Secrets
kubectl get pods -n external-secrets
```

## Troubleshooting

### Common Issues

1. **OIDC Provider Issues**:
   - Ensure the EKS cluster has an OIDC provider associated
   - Verify the OIDC provider ARN format

2. **GitOps Repository Access**:
   - Ensure SSH keys are properly configured for Git access
   - Verify repository URLs and permissions

3. **DNS Configuration**:
   - Check Route53 zone ARNs are correct
   - Verify domain ownership and DNS delegation

4. **Networking Issues**:
   - Ensure VPC and subnet configurations are correct
   - Check security group rules for ingress traffic

### Debugging Commands

```bash
# Check ArgoCD applications
kubectl get applications -n argocd

# Check ArgoCD application status
kubectl describe application <app-name> -n argocd

# View ArgoCD server logs
kubectl logs -n argocd deployment/argocd-server

# Check addon status
kubectl get pods --all-namespaces | grep -E "(external-dns|aws-load-balancer|karpenter)"
```

## Cleanup

To destroy the resources:

```bash
terraform destroy
```

**Note**: This will remove the GitOps bridge components but not the underlying EKS cluster.

## Security Considerations

- Store sensitive values (passwords, tokens) in environment variables or secure secret management systems
- Use least-privilege IAM policies
- Enable audit logging for the EKS cluster
- Regularly update addon versions
- Monitor ArgoCD access and application deployments

## Support

For issues and questions:
1. Check the main module documentation
2. Review Terraform plan output for validation errors
3. Check AWS CloudTrail logs for permission issues
4. Verify EKS cluster health and connectivity
