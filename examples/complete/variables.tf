################################################################################
# General Configuration
################################################################################

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "gitops-example"
}

################################################################################
# EKS Cluster Configuration
################################################################################

variable "cluster_name" {
  description = "Name of the existing EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster is deployed"
  type        = string
}

################################################################################
# GitOps Repository Configuration
################################################################################

variable "gitops_addons_org" {
  description = "Git repository org/user for addons"
  type        = string
  default     = "git@github.com:gitops-bridge-dev"
}

variable "gitops_addons_repo" {
  description = "Git repository for addons"
  type        = string
  default     = "gitops-bridge-argocd-control-plane-template"
}

variable "gitops_addons_revision" {
  description = "Git repository revision/branch/ref for addons"
  type        = string
  default     = "HEAD"
}

variable "gitops_addons_basepath" {
  description = "Git repository base path for addons"
  type        = string
  default     = "gitops/addons/"
}

variable "gitops_addons_path" {
  description = "Git repository path for addons"
  type        = string
  default     = "bootstrap/control-plane/addons"
}

variable "gitops_platform_org" {
  description = "Git repository org/user for platform"
  type        = string
  default     = "git@github.com:gitops-bridge-dev"
}

variable "gitops_platform_repo" {
  description = "Git repository for platform"
  type        = string
  default     = "gitops-platform"
}

variable "gitops_platform_revision" {
  description = "Git repository revision/branch/ref for platform"
  type        = string
  default     = "HEAD"
}

variable "gitops_platform_basepath" {
  description = "Git repository base path for platform"
  type        = string
  default     = ""
}

variable "gitops_platform_path" {
  description = "Git repository path for platform"
  type        = string
  default     = "bootstrap"
}

variable "gitops_workloads_org" {
  description = "Git repository org/user for workloads"
  type        = string
  default     = "git@github.com:gitops-bridge-dev"
}

variable "gitops_workloads_repo" {
  description = "Git repository for workloads"
  type        = string
  default     = "gitops-apps"
}

variable "gitops_workloads_revision" {
  description = "Git repository revision/branch/ref for workloads"
  type        = string
  default     = "HEAD"
}

variable "gitops_workloads_basepath" {
  description = "Git repository base path for workloads"
  type        = string
  default     = ""
}

variable "gitops_workloads_path" {
  description = "Git repository path for workloads"
  type        = string
  default     = ""
}

################################################################################
# GitOps Authentication
################################################################################

variable "gitops_user" {
  description = "GitOps user"
  type        = string
  default     = "gitops"
}

variable "gitops_password" {
  description = "GitOps password or token"
  type        = string
  sensitive   = true
  default     = null
}

################################################################################
# Kubernetes Addons Configuration
################################################################################

variable "enable_karpenter" {
  description = "Enable Karpenter for node provisioning"
  type        = bool
  default     = false
}

variable "enable_cluster_autoscaler" {
  description = "Enable Cluster Autoscaler"
  type        = bool
  default     = false
}

variable "enable_aws_node_termination_handler" {
  description = "Enable AWS Node Termination Handler"
  type        = bool
  default     = false
}

variable "enable_istio" {
  description = "Enable Istio service mesh"
  type        = bool
  default     = false
}

variable "enable_custom_certificates" {
  description = "Enable custom certificates"
  type        = bool
  default     = false
}

################################################################################
# DNS Configuration
################################################################################

variable "external_dns_domain_filters" {
  description = "Domain filters for External DNS"
  type        = list(string)
  default     = []
}

variable "private_route53_zone_arn" {
  description = "Private Route53 zone ARN"
  type        = list(string)
  default     = []
}

variable "public_route53_zone_arn" {
  description = "Public Route53 zone ARN"
  type        = list(string)
  default     = []
}

################################################################################
# VPC CNI Configuration
################################################################################

variable "vpc_cni_conf_mode" {
  description = "VPC CNI configuration mode"
  type        = string
  default     = "default_cfg"
  validation {
    condition     = contains(["custom_cfg", "default_cfg"], var.vpc_cni_conf_mode)
    error_message = "Allowed values for vpc_cni_conf_mode are custom_cfg, default_cfg."
  }
}

################################################################################
# Karpenter Configuration
################################################################################

variable "karpenter_discovery_tag" {
  description = "Karpenter tag for resource discovery"
  type        = string
  default     = "project"
}

################################################################################
# ArgoCD Configuration
################################################################################

variable "default_argoproj_name" {
  description = "Default ArgoCD project name"
  type        = string
  default     = "default-project"
}

variable "gitops_repositories" {
  description = "List of allowed repositories in ArgoCD AppProject"
  type        = list(string)
  default = [
    "https://aws.github.io/*",
    "https://kubernetes-sigs.github.io/*",
    "public.ecr.aws",
    "https://kiali.org/helm-charts",
    "https://charts.external-secrets.io",
    "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts",
    "https://istio-release.storage.googleapis.com/charts",
    "https://argoproj.github.io/argo-helm",
    "https://grafana.github.io/helm-charts",
    "public.ecr.aws/dynatrace"
  ]
}

################################################################################
# ArgoCD Ingress Configuration
################################################################################

variable "enable_argo_ingress" {
  description = "Enable ArgoCD ALB ingress"
  type        = bool
  default     = false
}

variable "argo_domain_name" {
  description = "Domain name for ArgoCD ingress"
  type        = string
  default     = "argocd.example.com"
}

variable "argo_zone_id" {
  description = "Route53 zone ID for ArgoCD domain"
  type        = string
  default     = ""
}

variable "argo_load_balancer_type" {
  description = "Load balancer type for ArgoCD (internal/internet-facing)"
  type        = string
  default     = "internal"
}

variable "argo_validation_type" {
  description = "Certificate validation type for ArgoCD"
  type        = string
  default     = "private"
}

################################################################################
# SSO Configuration
################################################################################

variable "enable_sso" {
  description = "Enable SSO integration with Entra ID"
  type        = bool
  default     = false
}

variable "tenant_id" {
  description = "Tenant ID for Microsoft Entra ID SSO"
  type        = string
  default     = null
}

variable "client_id" {
  description = "Client ID for Microsoft Entra ID SSO"
  type        = string
  default     = null
}

variable "client_secret" {
  description = "Client Secret for Microsoft Entra ID SSO"
  type        = string
  default     = null
  sensitive   = true
}

################################################################################
# User Management Configuration
################################################################################

variable "enable_user_management" {
  description = "Enable user management features"
  type        = bool
  default     = false
}

################################################################################
# Security Configuration
################################################################################

variable "internal_apps_domain_names" {
  description = "Domain names for internal applications"
  type        = list(string)
  default     = []
}

variable "core_cluster_apps_ingress_cidr" {
  description = "CIDR blocks for core cluster apps ingress"
  type        = list(string)
  default     = []
}

################################################################################
# Tags
################################################################################

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    Terraform = "true"
  }
}
