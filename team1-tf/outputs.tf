output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.resource_group.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = module.resource_group.id
}

output "location" {
  description = "Azure region the resources are deployed to"
  value       = module.resource_group.location
}

output "key_vault_name" {
  description = "Name of the Key Vault — add secrets here in the Azure portal"
  value       = module.key_vault.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = module.key_vault.vault_uri
}

output "frontend_url" {
  description = "Public URL of the frontend application"
  value       = module.container_apps.frontend_url
}

output "container_app_environment_domain" {
  description = "Default domain of the Container App Environment"
  value       = module.container_app_environment.default_domain
}
