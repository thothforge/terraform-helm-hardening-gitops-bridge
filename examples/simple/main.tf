################################################################################
# Simple Example - Terraform Hardening GitOps Bridge
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
# Simple GitOps Bridge Module Configuration
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

  # GitOps Configuration - Using defaults
  gitops_deployment_type = "single"

  # GitOps Authentication
  gitops_user     = var.gitops_user
  GITOPS_PASSWORD = var.gitops_password

  # Basic Addons - Essential ones only
  addons = {
    enable_aws_load_balancer_controller          = true
    enable_metrics_server                        = true
    enable_external_secrets                      = true
    enable_external_dns                          = false  # Disabled for simplicity
    enable_secrets_store_csi_driver              = true
    enable_secrets_store_csi_driver_provider_aws = true
    enable_karpenter                             = false  # Disabled for simplicity
    enable_cluster_autoscaler                    = false
    enable_aws_node_termination_handler          = false
    enable_argo_workflows                        = true
    enable_istio                                 = false  # Disabled for simplicity
    enable_grafana_loki                          = false  # Disabled for simplicity
  }

  # Minimal Configuration Metadata
  conf_metadata = {
    enable_karpenter_conf        = false
    enable_system_customizations = false
    enable_kafka_ops             = false
    enable_tm_namespaces         = false
    enable_cni_custom            = false
    enable_istio_extensions      = false
    enable_custom_certificates   = false
  }

  # VPC CNI - Default configuration
  vpc_cni_conf_mode = "default_cfg"

  # ArgoCD - Basic configuration
  default_argoproj_name = var.project_name
  
  # Disable advanced features for simplicity
  enable_argo_ingress = false
  enable_sso         = false

  # Basic user management
  user_management_config = {
    enabled                  = false
    store_in_secrets_manager = true
    password_length          = 16
    password_special_chars   = "!#$%&*()-_=+[]{}<>:?"
    bcrypt_cost              = 10
    default_role             = "role:readonly"
  }

  # Tags
  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Example     = "simple"
  }
}
