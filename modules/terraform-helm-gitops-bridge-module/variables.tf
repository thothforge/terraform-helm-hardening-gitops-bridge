variable "enable_argocd" {
  description = "Flag to enable or disable ArgoCD installation"
  type        = bool
  default     = true
}



variable "create_kubernetes_resources" {
  description = "Flag to create Kubernetes resources"
  type        = bool
  default     = true
}

variable "argocd" {
  description = "Configuration for ArgoCD"
  type = object({
    name                       = optional(string, "argo-cd")
    description                = optional(string, "A Helm chart to install the ArgoCD")
    namespace                  = optional(string, "argocd")
    create_namespace           = optional(bool, true)
    chart                      = optional(string, "argo-cd")
    chart_version              = optional(string, "8.0.10")
    repository                 = optional(string, "https://argoproj.github.io/argo-helm")
    values                     = optional(list(string), [])
    timeout                    = optional(number)
    repository_key_file        = optional(string)
    repository_cert_file       = optional(string)
    repository_ca_file         = optional(string)
    repository_username        = optional(string)
    repository_password        = optional(string)
    devel                      = optional(bool)
    verify                     = optional(bool)
    keyring                    = optional(string)
    disable_webhooks           = optional(bool)
    reuse_values               = optional(bool)
    reset_values               = optional(bool)
    force_update               = optional(bool)
    recreate_pods              = optional(bool)
    cleanup_on_fail            = optional(bool)
    max_history                = optional(number)
    atomic                     = optional(bool)
    skip_crds                  = optional(bool)
    render_subchart_notes      = optional(bool)
    disable_openapi_validation = optional(bool)
    wait                       = optional(bool, false)
    wait_for_jobs              = optional(bool)
    dependency_update          = optional(bool)
    replace                    = optional(bool)
    lint                       = optional(bool)
    postrender                 = optional(list(string), [])
    set                        = optional(list(map(string)), [])
    set_sensitive              = optional(list(map(string)), [])
  })
  default = {}

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.argocd.name))
    error_message = "The argocd.name must consist of lowercase alphanumeric characters and hyphens only."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.argocd.namespace))
    error_message = "The argocd.namespace must consist of lowercase alphanumeric characters and hyphens only."
  }

  validation {
    condition     = can(regex("^\\d+\\.\\d+\\.\\d+$", var.argocd.chart_version))
    error_message = "The argocd.chart_version must be in the format 'X.Y.Z'."
  }

  validation {
    condition     = can(regex("^https?://", var.argocd.repository))
    error_message = "The argocd.repository must be a valid URL starting with http:// or https://."
  }
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "apps" {
  description = "argocd app of apps to deploy"
  type        = any
  default     = {}
}


variable "cluster" {
  description = "argocd cluster secret"
  type        = any
  default     = null
}


################################################################################################
# Local user management by default is disabled. To enable it, set the following variables to true
###################################################################################################
variable "argocd_users" {
  description = "Map of ArgoCD users and their configurations"
  type = map(object({
    groups = list(string)
    roles  = list(string)
  }))
  default = {
    admin = {
      groups = ["group-admins"]
      roles  = ["role:admin"]
    }
    developer = {
      groups = ["group-developers"]
      roles  = ["role:developer"]
    }
    viewer = {
      groups = ["group-viewers"]
      roles  = ["role:readonly"]
    }
  }
}

variable "user_management_config" {
  description = "Configuration for user management features"
  type = object({
    enabled                  = bool
    store_in_secrets_manager = bool
    password_length          = number
    password_special_chars   = string
    bcrypt_cost              = number
    default_role             = string
  })
  default = {
    enabled                  = false
    store_in_secrets_manager = true
    password_length          = 16
    password_special_chars   = "!#$%&*()-_=+[]{}<>:?"
    bcrypt_cost              = 10
    default_role             = "role:readonly"
  }
}

# kms for argo secrets
variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = null
}
variable "enable_argo_ingress" {
  description = "Flag to enable or disable ArgoCD ingress installation"
  type        = bool
  default     = true
}