################################################################################
# GitOps Bridge Outputs
################################################################################

output "addons" {
  description = "EKS Addons configuration and status"
  value       = module.gitops_bridge.addons
}

################################################################################
# Cluster Information
################################################################################

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = var.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for the EKS cluster"
  value       = data.aws_eks_cluster.cluster.endpoint
}

output "cluster_version" {
  description = "Version of the EKS cluster"
  value       = data.aws_eks_cluster.cluster.version
}

output "cluster_platform_version" {
  description = "Platform version of the EKS cluster"
  value       = data.aws_eks_cluster.cluster.platform_version
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC Provider for the EKS cluster"
  value       = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

################################################################################
# Network Information
################################################################################

output "vpc_id" {
  description = "VPC ID where the cluster is deployed"
  value       = var.vpc_id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = data.aws_subnets.private.ids
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = data.aws_subnets.public.ids
}

################################################################################
# GitOps Configuration
################################################################################

output "gitops_deployment_type" {
  description = "GitOps deployment architecture type"
  value       = "single"
}

output "gitops_addons_repo" {
  description = "GitOps addons repository"
  value       = var.gitops_addons_repo
}

output "gitops_platform_repo" {
  description = "GitOps platform repository"
  value       = var.gitops_platform_repo
}

output "gitops_workloads_repo" {
  description = "GitOps workloads repository"
  value       = var.gitops_workloads_repo
}

################################################################################
# ArgoCD Configuration
################################################################################

output "argocd_namespace" {
  description = "Namespace where ArgoCD is deployed"
  value       = "argocd"
}

output "argocd_ingress_enabled" {
  description = "Whether ArgoCD ingress is enabled"
  value       = var.enable_argo_ingress
}

output "argocd_domain_name" {
  description = "Domain name for ArgoCD access (if ingress enabled)"
  value       = var.enable_argo_ingress ? var.argo_domain_name : null
}

################################################################################
# Enabled Addons
################################################################################

output "enabled_addons" {
  description = "List of enabled Kubernetes addons"
  value = {
    aws_load_balancer_controller          = true
    metrics_server                        = true
    external_secrets                      = true
    external_dns                          = true
    secrets_store_csi_driver              = true
    secrets_store_csi_driver_provider_aws = true
    karpenter                             = var.enable_karpenter
    cluster_autoscaler                    = var.enable_cluster_autoscaler
    aws_node_termination_handler          = var.enable_aws_node_termination_handler
    argo_workflows                        = true
    istio                                 = var.enable_istio
    grafana_loki                          = true
  }
}

################################################################################
# Security Configuration
################################################################################

output "sso_enabled" {
  description = "Whether SSO integration is enabled"
  value       = var.enable_sso
}

output "user_management_enabled" {
  description = "Whether user management features are enabled"
  value       = var.enable_user_management
}

################################################################################
# Tags
################################################################################

output "tags" {
  description = "Tags applied to resources"
  value = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Example     = "complete"
  })
}
