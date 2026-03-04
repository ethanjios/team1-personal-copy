output "fqdn" {
  description = "Fully qualified domain name of the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.this.fqdn
}

output "db_name" {
  description = "Name of the created database"
  value       = azurerm_postgresql_flexible_server_database.this.name
}

output "admin_login" {
  description = "Administrator login name"
  value       = var.admin_login
}

output "admin_password" {
  description = "Generated administrator password"
  value       = random_password.db_password.result
  sensitive   = true
}

output "port" {
  description = "PostgreSQL port"
  value       = 5432
}
