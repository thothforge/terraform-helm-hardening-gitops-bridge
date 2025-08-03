################################################################################
# Complete Example - Terraform Hardening GitOps Bridge
################################################################################

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data sources to get existing EKS cluster information
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  
  tags = {
    Type = "Private"
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  
  tags = {
    Type = "Public"
  }
}

# Configure Kubernetes provider
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# Configure Helm provider
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

################################################################################
# GitOps Bridge Module
################################################################################

module "gitops_bridge" {
  source = "../../"

  # Basic Configuration
  enable       = true
  project_name = var.project_name
  
  # EKS Cluster Configuration
  cluster_name                         = var.cluster_name
  cluster_version                      = data.aws_eks_cluster.cluster.version
  cluster_endpoint                     = data.aws_eks_cluster.cluster.endpoint
  cluster_platform_version             = data.aws_eks_cluster.cluster.platform_version
  cluster_certificate_authority_data   = data.aws_eks_cluster.cluster.certificate_authority[0].data
  oidc_provider_arn                    = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer

  # Network Configuration
  vpc_id             = var.vpc_id
  private_subnet_ids = data.aws_subnets.private.ids
  public_subnet_ids  = data.aws_subnets.public.ids

  # GitOps Configuration
  gitops_deployment_type = "single"
  
  # Addons Repository Configuration
  gitops_addons_org      = var.gitops_addons_org
  gitops_addons_repo     = var.gitops_addons_repo
  gitops_addons_revision = var.gitops_addons_revision
  gitops_addons_basepath = var.gitops_addons_basepath
  gitops_addons_path     = var.gitops_addons_path

  # Platform Repository Configuration
  gitops_platform_org      = var.gitops_platform_org
  gitops_platform_repo     = var.gitops_platform_repo
  gitops_platform_revision = var.gitops_platform_revision
  gitops_platform_basepath = var.gitops_platform_basepath
  gitops_platform_path     = var.gitops_platform_path

  # Workloads Repository Configuration
  gitops_workloads_org      = var.gitops_workloads_org
  gitops_workloads_repo     = var.gitops_workloads_repo
  gitops_workloads_revision = var.gitops_workloads_revision
  gitops_workloads_basepath = var.gitops_workloads_basepath
  gitops_workloads_path     = var.gitops_workloads_path

  # GitOps Authentication
  gitops_user     = var.gitops_user
  GITOPS_PASSWORD = var.gitops_password

  # Kubernetes Addons Configuration
  addons = {
    enable_aws_load_balancer_controller          = true
    enable_metrics_server                        = true
    enable_external_secrets                      = true
    enable_external_dns                          = true
    enable_secrets_store_csi_driver              = true
    enable_secrets_store_csi_driver_provider_aws = true
    enable_karpenter                             = var.enable_karpenter
    enable_cluster_autoscaler                    = var.enable_cluster_autoscaler
    enable_aws_node_termination_handler          = var.enable_aws_node_termination_handler
    enable_argo_workflows                        = true
    enable_istio                                 = var.enable_istio
    enable_grafana_loki                          = true
  }

  # Configuration Metadata
  conf_metadata = {
    enable_karpenter_conf        = var.enable_karpenter
    enable_system_customizations = true
    enable_kafka_ops             = false
    enable_tm_namespaces         = false
    enable_cni_custom            = var.vpc_cni_conf_mode == "custom_cfg"
    enable_istio_extensions      = var.enable_istio
    enable_custom_certificates   = var.enable_custom_certificates
  }

  # DNS Configuration
  external_dns_domain_filters = var.external_dns_domain_filters
  private_route53_zone_arn    = var.private_route53_zone_arn
  public_route53_zone_arn     = var.public_route53_zone_arn

  # VPC CNI Configuration
  vpc_cni_conf_mode = var.vpc_cni_conf_mode

  # Karpenter Configuration
  karpenter_discovery_tag = var.karpenter_discovery_tag

  # ArgoCD Configuration
  default_argoproj_name = var.default_argoproj_name
  gitops_repositories   = var.gitops_repositories

  # ArgoCD Ingress Configuration
  enable_argo_ingress = var.enable_argo_ingress
  argo_host_dns = var.enable_argo_ingress ? {
    domain_name            = var.argo_domain_name
    zone_id                = var.argo_zone_id
    aws_load_balancer_type = var.argo_load_balancer_type
    validation             = var.argo_validation_type
  } : null

  # SSO Configuration
  enable_sso    = var.enable_sso
  tenant_id     = var.tenant_id
  client_id     = var.client_id
  client_secret = var.client_secret

  # User Management Configuration
  user_management_config = {
    enabled                  = var.enable_user_management
    store_in_secrets_manager = true
    password_length          = 16
    password_special_chars   = "!#$%&*()-_=+[]{}<>:?"
    bcrypt_cost              = 10
    default_role             = "role:readonly"
  }

  # Custom Certificates
  internal_apps_domain_names = var.internal_apps_domain_names

  # Security Configuration
  core_cluster_apps_ingress_cidr = var.core_cluster_apps_ingress_cidr

  # Tags
  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Example     = "complete"
  })
}
