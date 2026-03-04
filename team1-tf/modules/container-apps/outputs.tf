output "frontend_url" {
  description = "Public URL of the frontend application"
  value       = "https://${azurerm_container_app.frontend.ingress[0].fqdn}"
}

output "backend_internal_url" {
  description = "Internal URL of the backend (accessible only within the Container App Environment)"
  value       = "https://${azurerm_container_app.backend.name}.internal.${var.env_default_domain}"
}

output "frontend_name" {
  description = "Name of the frontend Container App"
  value       = azurerm_container_app.frontend.name
}

output "backend_name" {
  description = "Name of the backend Container App"
  value       = azurerm_container_app.backend.name
}
