output "id" {
  description = "Resource ID of the Container App Environment"
  value       = azurerm_container_app_environment.this.id
}

output "default_domain" {
  description = "Default domain of the environment — used to construct app FQDNs"
  value       = azurerm_container_app_environment.this.default_domain
}

output "static_ip_address" {
  description = "Static IP of the environment"
  value       = azurerm_container_app_environment.this.static_ip_address
}
