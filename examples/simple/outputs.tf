################################################################################
# Simple Example Outputs
################################################################################

output "addons" {
  description = "EKS Addons configuration and status"
  value       = module.gitops_bridge.addons
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = var.cluster_name
}

output "argocd_namespace" {
  description = "Namespace where ArgoCD is deployed"
  value       = "argocd"
}

output "enabled_addons" {
  description = "List of enabled Kubernetes addons"
  value = {
    aws_load_balancer_controller          = true
    metrics_server                        = true
    external_secrets                      = true
    secrets_store_csi_driver              = true
    secrets_store_csi_driver_provider_aws = true
    argo_workflows                        = true
  }
}
