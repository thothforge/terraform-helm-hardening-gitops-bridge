output "addons" {
  value       = try(module.eks_blueprints_addons[0], {})
  description = "EKS Addons"
}
