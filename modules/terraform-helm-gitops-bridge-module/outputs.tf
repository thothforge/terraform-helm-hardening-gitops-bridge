
output "argocd" {
  description = "Map of attributes of the Helm release created"
  value       = module.argocd
}

# Output the generated passwords only if enabled
output "argocd_user_credentials" {
  value = var.user_management_config.enabled ? {
    for username, password in random_password.argocd_users : username => {
      password = password.result
      hash     = bcrypt(password.result)
    }
  } : null
  sensitive = true
}
