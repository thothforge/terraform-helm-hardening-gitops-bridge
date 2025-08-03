output "cluster_addons" {
  description = "Map of attribute maps for all EKS cluster addons enabled"
  value       = merge(aws_eks_addon.this, aws_eks_addon.before_compute)
}

output "cluster_addons_versions" {
  description = "Map of versions for all EKS cluster addons enabled"
  value       = { for k, v in merge(aws_eks_addon.this, aws_eks_addon.before_compute) : k => v.addon_version }
}


output "eks_addons_before_compute" {
  description = "Map of EKS add-ons created before compute and their attributes"
  value       = aws_eks_addon.before_compute
}
