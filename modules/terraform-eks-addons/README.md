# EKS Addons Module

This module manages EKS cluster addons.

## Usage

```hcl
module "eks_addons" {
  source = "./modules/eks-addons"

  kubernetes_version = aws_eks_cluster.example.version
  
  cluster_addons = {
    coredns = {
      preserve = true
      most_recent = true
    }
    kube-proxy = {}
    vpc-cni = {
      most_recent = true
      service_account_role_arn = aws_iam_role.vpc_cni.arn
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
    aws-ebs-csi-driver = {
      service_account_role_arn = aws_iam_role.ebs_csi_driver.arn
      before_compute = true
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_addons | Map of cluster addon configurations to enable for the cluster | `any` | `{}` | no |
| kubernetes_version | Kubernetes version to use for the EKS cluster | `string` | `null` | no |
| cluster_addons_timeouts | Create, update, and delete timeout configurations for the cluster addons | `map(string)` | `{}` | no |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_addons | Map of attribute maps for all EKS cluster addons enabled |
| cluster_addons_versions | Map of versions for all EKS cluster addons enabled |
