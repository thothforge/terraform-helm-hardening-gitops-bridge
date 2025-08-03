
/*
* # Module for terraform-helm-gitops-bridge-module deployment
*
* Terraform stack to provision a custom terraform-helm-gitops-bridge-module using the following Terraform modules and resources:
*
* ## Modules & Resources
*
* ### Module <module_name>
*
* **Source Module info:**
* - **Name**    : **<module_name>**
* - **Version** : "<module_version>"
* - **Link**    :  [URL](<module_url>)
*
*/

################################################################################
# ArgoCD
################################################################################

module "argocd" {
  source  = "aws-ia/eks-blueprints-addon/aws"
  version = "1.1.1"
  create = var.enable_argocd && var.create_kubernetes_resources ? true : false

  # Disable helm release
  create_release = var.create_kubernetes_resources

  # https://github.com/argoproj/argo-helm/blob/main/charts/argo-cd/Chart.yaml
  name             = try(var.argocd.name, "argo-cd")
  description      = try(var.argocd.description, "A Helm chart to install the ArgoCD")
  namespace        = try(var.argocd.namespace, "argocd")
  create_namespace = try(var.argocd.create_namespace, true)
  chart            = try(var.argocd.chart, "argo-cd")
  chart_version    = try(var.argocd.chart_version, "8.0.10")
  repository       = try(var.argocd.repository, "https://argoproj.github.io/argo-helm")
  #values           = try(var.argocd.values, [])
  values = try(local.argocd_values, [])

  timeout                    = try(var.argocd.timeout, null)
  repository_key_file        = try(var.argocd.repository_key_file, null)
  repository_cert_file       = try(var.argocd.repository_cert_file, null)
  repository_ca_file         = try(var.argocd.repository_ca_file, null)
  repository_username        = try(var.argocd.repository_username, null)
  repository_password        = try(var.argocd.repository_password, null)
  devel                      = try(var.argocd.devel, null)
  verify                     = try(var.argocd.verify, null)
  keyring                    = try(var.argocd.keyring, null)
  disable_webhooks           = try(var.argocd.disable_webhooks, null)
  reuse_values               = try(var.argocd.reuse_values, null)
  reset_values               = try(var.argocd.reset_values, null)
  force_update               = try(var.argocd.force_update, null)
  recreate_pods              = try(var.argocd.recreate_pods, null)
  cleanup_on_fail            = try(var.argocd.cleanup_on_fail, null)
  max_history                = try(var.argocd.max_history, null)
  atomic                     = try(var.argocd.atomic, null)
  skip_crds                  = try(var.argocd.skip_crds, null)
  render_subchart_notes      = try(var.argocd.render_subchart_notes, null)
  disable_openapi_validation = try(var.argocd.disable_openapi_validation, null)
  wait                       = try(var.argocd.wait, false)
  wait_for_jobs              = try(var.argocd.wait_for_jobs, null)
  dependency_update          = try(var.argocd.dependency_update, null)
  replace                    = try(var.argocd.replace, null)
  lint                       = try(var.argocd.lint, null)

  postrender    = try(var.argocd.postrender, [])
  set           = try(var.argocd.set, [])
  set_sensitive = try(var.argocd.set_sensitive, [])

  tags                     = var.tags



}



################################################################################
# ArgoCD Cluster
################################################################################
locals {
  cluster_name = try(var.cluster.cluster_name, "in-cluster")
  environment  = try(var.cluster.environment, "dev")
  argocd_labels = merge({
    cluster_name                     = local.cluster_name
    environment                      = local.environment
    enable_argocd                    = true
    "argocd.argoproj.io/secret-type" = "cluster"
    },
    try(var.cluster.addons, {})
  )
  argocd_annotations = merge(
    {
      cluster_name = local.cluster_name
      environment  = local.environment
    },
    try(var.cluster.metadata, {})
  )
}

locals {
  config = <<-EOT
    {
      "tlsClientConfig": {
        "insecure": false
      }
    }
  EOT
  argocd = {
    apiVersion = "v1"
    kind       = "Secret"
    metadata = {
      name        = try(var.cluster.secret_name, local.cluster_name)
      namespace   = try(var.cluster.secret_namespace, "argocd")
      annotations = local.argocd_annotations
      labels      = local.argocd_labels
    }
    stringData = {
      name   = local.cluster_name
      server = try(var.cluster.server, "https://kubernetes.default.svc")
      config = try(var.cluster.config, local.config)
    }
  }
}
resource "kubernetes_secret_v1" "cluster_secret" {
  count = var.enable_argocd && (var.cluster != null) ? 1 : 0

  metadata {
    name        = local.argocd.metadata.name
    namespace   = local.argocd.metadata.namespace
    annotations = local.argocd.metadata.annotations
    labels      = local.argocd.metadata.labels
  }
  data = local.argocd.stringData

  depends_on = [module.argocd]
}


################################################################################
# Create App of Apps
################################################################################
resource "helm_release" "bootstrap" {
  for_each = var.enable_argocd ? var.apps : {}

  name      = each.key
  namespace = try(var.argocd.namespace, "argocd")
  chart     = "${path.module}/charts/resources"
  version   = "1.0.0"

  values = [
    <<-EOT
    resources:
      - ${indent(4, each.value)}
    EOT
  ]

  depends_on = [
    kubernetes_secret_v1.cluster_secret

  ]
}
############################################################################################
# Local user
###########################################################################################
# Generate random passwords
resource "random_password" "argocd_users" {
  for_each = var.user_management_config.enabled ? var.argocd_users : {}

  length           = var.user_management_config.password_length
  special          = true
  override_special = var.user_management_config.password_special_chars
}

# Store passwords in AWS Secrets Manager
resource "aws_secretsmanager_secret" "argocd_users" {
  for_each = var.user_management_config.enabled && var.user_management_config.store_in_secrets_manager ? random_password.argocd_users : {}

  name        = "argocd/users/${each.key}"
  description = "ArgoCD user password for ${each.key}"
  kms_key_id  = var.kms_key_id
}

resource "aws_secretsmanager_secret_version" "argocd_users" {
  for_each = var.user_management_config.enabled && var.user_management_config.store_in_secrets_manager ? random_password.argocd_users : {}

  secret_id = aws_secretsmanager_secret.argocd_users[each.key].id
  secret_string = jsonencode({
    username = each.key
    password = each.value.result
    hash     = bcrypt(each.value.result, var.user_management_config.bcrypt_cost)
  })
}
locals {
  # Get the original values YAML
  original_values = length(try(var.argocd.values, [])) > 0 ? var.argocd.values[0] : "{}"

  # Parse the original values
  parsed_original = yamldecode(local.original_values)

  # Correctly access the existing RBAC policy under configs.rbac
  existing_rbac_policy = try(lookup(lookup(lookup(local.parsed_original, "configs", {}), "rbac", {}), "policy.csv", ""), "")

  # Safely handle group memberships and role assignments with null checks
  user_groups = var.user_management_config.enabled ? flatten([
    for username, config in coalesce(var.argocd_users, {}) : [
      for group in coalesce(try(config.groups, []), []) :
      "g, ${username}, ${group}"
    ] if can(config.groups)
  ]) : []

  user_roles = var.user_management_config.enabled ? flatten([
    for username, config in coalesce(var.argocd_users, {}) : [
      for role in coalesce(try(config.roles, []), []) :
      "g, ${username}, ${role}"
    ] if can(config.roles)
  ]) : []

  group_memberships = var.user_management_config.enabled ? (
    length(local.user_groups) > 0 ? join("\n", local.user_groups) : ""
  ) : ""

  role_assignments = var.user_management_config.enabled ? (
    length(local.user_roles) > 0 ? join("\n", local.user_roles) : ""
  ) : ""

  # Generate user RBAC policy if enabled - with safer handling
  user_rbac_policy = var.user_management_config.enabled ? (<<-EOT
${length(local.group_memberships) > 0 ? "# Group memberships\n${local.group_memberships}\n" : ""}
${length(local.role_assignments) > 0 ? "# Role assignments\n${local.role_assignments}\n" : ""}

# Admin permissions
p, role:admin, applications, *, */*, allow
p, role:admin, projects, *, *, allow
p, role:admin, clusters, *, *, allow
p, role:admin, repositories, *, *, allow
p, role:admin, certificates, *, *, allow

# Developer permissions
p, role:developer, applications, get, */*, allow
p, role:developer, applications, sync, */*, allow
p, role:developer, projects, get, *, allow
p, role:developer, logs, get, */*, allow

# Team specific permissions
p, role:team-a-access, applications, *, team-a/*, allow
p, role:team-b-access, applications, *, team-b/*, allow

# Allow all destinations and resources
p, role:admin, *, *, *, allow
EOT
  ) : ""

  # Final RBAC policy - concatenate if both exist
  final_rbac_policy = var.user_management_config.enabled ? (
    local.existing_rbac_policy != "" ?
    "${local.user_rbac_policy}\n\n# Existing RBAC policy\n${local.existing_rbac_policy}" :
    local.user_rbac_policy
  ) : local.existing_rbac_policy

  # Generate user accounts with proper capabilities
  user_accounts_with_passwords = var.user_management_config.enabled ? {
    for username, password in coalesce(random_password.argocd_users, {}) :
    "accounts.${username}.password" => bcrypt(password.result, var.user_management_config.bcrypt_cost)
  } : {}

  # Add the enabled flag
  user_accounts_with_enabled = var.user_management_config.enabled ? {
    for username, _ in coalesce(var.argocd_users, {}) :
    "accounts.${username}.enabled" => "true"
  } : {}
  user_accounts_with_login = var.user_management_config.enabled ? {
    for username, _ in coalesce(var.argocd_users, {}) :
    "accounts.${username}" => "login"
  } : {}

  # Process group memberships
  user_accounts_with_groups = var.user_management_config.enabled ? {
    for username, config in coalesce(var.argocd_users, {}) :
    "accounts.${username}.groups" => join(",", coalesce(try(config.groups, []), []))
    if length(coalesce(try(config.groups, []), [])) > 0
  } : {}

  # Merge all account configurations
  user_accounts = var.user_management_config.enabled ? merge(
    local.user_accounts_with_passwords,
    local.user_accounts_with_enabled,
    local.user_accounts_with_login,
    local.user_accounts_with_groups
  ) : {}

  # Create modified values by adding our configurations
  modified_values = var.user_management_config.enabled ? (
    yamlencode(merge(
      local.parsed_original,
      {
        configs = merge(
          lookup(local.parsed_original, "configs", {}),
          {
            cm = merge(
              lookup(lookup(local.parsed_original, "configs", {}), "cm", {}),
              local.user_accounts
            ),
            rbac = merge(
              lookup(lookup(local.parsed_original, "configs", {}), "rbac", {}),
              {
                "policy.csv"     = local.final_rbac_policy,
                "policy.default" = var.user_management_config.default_role,
                "scopes"         = "[groups, name]" # Make sure this is included
              }
            )
          }
        )
      }
    ))
  ) : local.original_values
  should_manage_users = var.enable_argocd && var.user_management_config.enabled

  # Merge existing secret data with new passwords
  # Remove any old password entries that are no longer needed
  existing_secret_data = local.should_manage_users ? {
    for k, v in data.kubernetes_secret_v1.existing_argocd_secret[0].data :
    k => v if !startswith(k, "accounts.") || !endswith(k, ".password")
  } : {}
  # Combine existing data with new passwords
  merged_secret_data = merge(
    local.existing_secret_data,
    local.user_accounts_with_passwords
  )
  # Final values to use
  argocd_values = [local.modified_values]
}
# data source to get the existing secret
data "kubernetes_secret_v1" "existing_argocd_secret" {
  count = local.should_manage_users ? 1 : 0
  metadata {
    name      = "argocd-secret"
    namespace = "argocd"
  }
}

# Update only the data of the existing secret
resource "kubernetes_secret_v1_data" "argocd_secret_data" {
  count = local.should_manage_users ? 1 : 0
  metadata {
    name      = "argocd-secret"
    namespace = "argocd"
  }

  data = local.merged_secret_data

  force = true

  depends_on = [
    data.kubernetes_secret_v1.existing_argocd_secret
  ]

}

/*
resource "kubernetes_service_v1" "argogrpc" {
  count = var.enable_argo_ingress ? 1 : 0
  metadata {
    name      = "argogrpc"
    namespace = "argocd"

    annotations = {
      "alb.ingress.kubernetes.io/backend-protocol-version" = "GRPC"
    }

    labels = {
      app = "argogrpc"
    }
  }

  spec {
    port {
      name        = "443"
      port        = 443
      protocol    = "TCP"
      target_port = 8080
    }

    selector = {
      "app.kubernetes.io/name" = "argocd-server"
    }

    session_affinity = "None"
    type            = "NodePort"
  }
}
*/