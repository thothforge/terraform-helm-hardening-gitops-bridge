
/*
* # Module for terraform-hardening-gitops-bridge deployment
*
* Terraform stack to provision a custom terraform-hardening-gitops-bridge
*
*/

module "hardening_gitops_bridge" {
  source  = "./modules/terraform-helm-gitops-bridge-module" #"gitops-bridge-dev/gitops-bridge/helm"

  cluster = {
      cluster_name = var.cluster_name
      environment  = local.environment # argo environments
      metadata     = local.addons_metadata
      addons       = local.addons
    }

    apps                   = local.argocd_apps
    user_management_config = var.user_management_config
    enable_argo_ingress    = var.enable_argo_ingress
    argocd = {
      namespace = "argocd"
      #set = [
      #  {
      #    name  = "server.service.type"
      #    value = "LoadBalancer"
      #  }
      #]
      values = [
        yamlencode(
          yamldecode(local.argocd_values)
        )
      ]

    }
    tags= var.tags
}

################################################################################
# Security group if ingress gateway is enabled
################################################################################
module "core_ingress_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"
  count                  = var.enable && (var.addons.enable_istio || var.enable_argo_ingress) ? 1 : 0
  create_sg              = true
  vpc_id                 = var.vpc_id
  name                   = "${var.cluster_name}-core-ingress-sg"
  revoke_rules_on_delete = true

  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "TCP"
      description = "For Cluster ingress ALB"
      cidr_blocks = join(",", var.core_cluster_apps_ingress_cidr)

    }
  ]
  egress_rules = [
    "all-all"
  ]

}

# Allow node's sg traffic from alb
module "node_alb_traffic_rules" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"
  count                  = var.enable && (var.addons.enable_istio || var.enable_argo_ingress) ? 1 : 0
  create_sg              = false
  security_group_id      = var.node_security_group
  revoke_rules_on_delete = true
  ingress_with_source_security_group_id = [
    {
      from_port                = 443
      to_port                  = 443
      protocol                 = "TCP"
      description              = "For Cluster ingress ALB"
      source_security_group_id = module.core_ingress_sg[0].security_group_id

    },
    {
      from_port                = 8080
      to_port                  = 8080
      protocol                 = "TCP"
      description              = "For Cluster ingress ALB"
      source_security_group_id = module.core_ingress_sg[0].security_group_id

    },
    {
      from_port                = 80
      to_port                  = 80
      protocol                 = "TCP"
      description              = "For Cluster ingress ALB"
      source_security_group_id = module.core_ingress_sg[0].security_group_id

    },
    {
      from_port                = 30000
      to_port                  = 32767
      protocol                 = "TCP"
      description              = "For Cluster ingress ALB"
      source_security_group_id = module.core_ingress_sg[0].security_group_id

    }
  ]

}
################################################################################
# GitOps Bridge: Private ssh keys for git
################################################################################

# get password from
# TODO change credentials to use https and Ephemeral path
# TODO change to use aws secrets manager
resource "kubernetes_secret" "git_secrets" {

  depends_on = [module.hardening_gitops_bridge]
  for_each = var.gitops_deployment_type == "single" && var.enable ? {
    git-addons = {
      type     = "git"
      url      = local.gitops_addons_org
      username = var.gitops_user
      password = var.GITOPS_PASSWORD
    }
    git-platform = {
      type     = "git"
      url      = local.gitops_platform_url
      username = var.gitops_user
      password = var.GITOPS_PASSWORD
    }
    git-workloads = {
      type     = "git"
      url      = local.gitops_workloads_url
      username = var.gitops_user
      password = var.GITOPS_PASSWORD
    }

  } : {}
  metadata {
    name      = each.key
    namespace = try(module.hardening_gitops_bridge[0].argocd.namespace, "argocd") #kubernetes_namespace.argocd.metadata[0].name
    labels = {
      "argocd.argoproj.io/secret-type" = "repo-creds"
    }
  }
  data = each.value
}

################################################################################
# ArgoCD EKS Access
################################################################################
module "argocd_irsa" {
 source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.1.1"
  count  = var.enable ? 1 : 0

  create_release             = false
  create_role                = true
  role_name_use_prefix       = false
  role_name                  = "${var.project_name}-devsecops-argocd-hub"
  assume_role_condition_test = "StringLike"
  create_policy              = false
  role_policies = {
    ArgoCD_EKS_Policy = aws_iam_policy.irsa_policy[0].arn
  }
  oidc_providers = {
    this = {
      provider_arn    = var.oidc_provider_arn
      namespace       = "argocd"
      service_account = "argocd-*"
    }
  }
  tags = var.tags
}

resource "aws_iam_policy" "irsa_policy" {
  count       = var.enable ? 1 : 0
  name        = "${var.cluster_name}-argocd-irsa"
  description = "IAM Policy for ArgoCD Hub"
  policy      = data.aws_iam_policy_document.irsa_policy.json
  tags        = var.tags
}


# EKS  Addons
################################################################################
module "eks_blueprints_addons" {
  source           = "aws-ia/eks-blueprints-addons/aws"
  version          = "1.21.1"
  count            = var.enable ? 1 : 0
  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  cluster_version  = var.cluster_version
  oidc_provider_arn = var.oidc_provider_arn

  # Using GitOps Bridge
  create_kubernetes_resources = false

  enable_aws_load_balancer_controller = local.aws_addons.enable_aws_load_balancer_controller
  enable_external_secrets             = local.aws_addons.enable_external_secrets

  enable_external_dns            = local.aws_addons.enable_external_dns
  external_dns_route53_zone_arns = local.external_dns_route53_zone_arns
  #external_dns    = var.external_dns_domain_filters

  #enable_secrets_store_csi_driver              = local.addons.
  enable_secrets_store_csi_driver_provider_aws = local.aws_addons.enable_secrets_store_csi_driver_provider_aws
  enable_karpenter                             = local.aws_addons.enable_karpenter

  karpenter_node = {
    iam_role_name = "${var.project_name}-karpenter"
    #iam_role_name = "${var.cluster_name}-kpt"
  }


  enable_cluster_autoscaler             = local.aws_addons.enable_cluster_autoscaler
  enable_aws_node_termination_handler   = local.aws_addons.enable_aws_node_termination_handler
  aws_node_termination_handler_asg_arns = var.eks_auto_scaling_groups_arns


  # EKS Blueprints Addons
  #enable_cert_manager                 = local.aws_addons.enable_cert_manager
  #enable_aws_efs_csi_driver           = local.aws_addons.enable_aws_efs_csi_driver
  #enable_aws_fsx_csi_driver           = local.aws_addons.enable_aws_fsx_csi_driver
  #enable_aws_cloudwatch_metrics       = local.aws_addons.enable_aws_cloudwatch_metrics
  #enable_aws_privateca_issuer         = local.aws_addons.enable_aws_privateca_issuer
  #
  #
  #enable_external_secrets             = local.workspace["aws_addons"]["enable_external_secrets"]

  #enable_fargate_fluentbit            = local.aws_addons.enable_fargate_fluentbit
  #enable_aws_for_fluentbit            = local.aws_addons.enable_aws_for_fluentbit
  #
  #
  #enable_velero                       = local.aws_addons.enable_velero
  #enable_aws_gateway_api_controller   = local.aws_addons.enable_aws_gateway_api_controller

  tags                     = var.tags

}


module "aws_vpc_cni_ipv4_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "1.12.1"
  name = "aws-vpc-cni-ipv4"

  attach_aws_vpc_cni_policy          = true
  aws_vpc_cni_enable_ipv4            = true
  aws_vpc_cni_enable_cloudwatch_logs = true


  # Pod Identity Associations
  association_defaults = {
    namespace       = "kube-system"
    service_account = "aws-node"
  }
  associations = {
    main = {
      cluster_name = var.cluster_name
    }
  }

  tags              = var.tags

}

module "eks_vpc_cni_native_addons" {
  source    =  "./modules/terraform-eks-addons"
  count     = var.enable ? 1 : 0
  #providers = { aws = aws.eks }

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  cluster_addons  = local.cluster_vpc_cni_addon
  tags            = var.tags

}
module "eks_native_addons" {
  source    = "./modules/terraform-eks-addons"
  count     = var.enable ? 1 : 0
  #providers = { aws = aws.eks }

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  cluster_addons  = local.cluster_addons

  tags = var.tags
  depends_on = [
    module.eks_vpc_cni_native_addons
  ]

}

######################################################################################
# Argo additional resources
######################################################################################
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"
  count   = var.enable_argo_ingress && var.argo_host_dns.validation == "public"? 1  : 0

  domain_name = var.argo_host_dns.domain_name
  zone_id     = var.argo_host_dns.zone_id

  validation_method = "DNS"

  wait_for_validation = true

  tags = var.tags
}
