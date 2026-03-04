terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# ---------------------------------------------------------------
# Generate a secure random password for the DB admin account
# Uses only URL-safe special chars so it works in the connection string
# ---------------------------------------------------------------
resource "random_password" "db_password" {
  length           = 20
  special          = true
  override_special = "!#$"
  min_lower        = 2
  min_upper        = 2
  min_numeric      = 2
}

# ---------------------------------------------------------------
# PostgreSQL Flexible Server
# ---------------------------------------------------------------
resource "azurerm_postgresql_flexible_server" "this" {
  name                = var.server_name
  resource_group_name = var.resource_group_name
  location            = var.location
  version             = "16"

  administrator_login    = var.admin_login
  administrator_password = random_password.db_password.result

  sku_name   = "B_Standard_B1ms"
  storage_mb = 32768 # 32 GB minimum

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  tags = var.tags

  lifecycle {
    # Zone is assigned by Azure on first creation and can't be freely changed
    ignore_changes = [zone]
  }
}

# Allow connections from other Azure services (e.g. Container Apps)
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_postgresql_flexible_server.this.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Disable SSL requirement — simplifies connection from Container Apps in dev
resource "azurerm_postgresql_flexible_server_configuration" "disable_ssl" {
  name      = "require_secure_transport"
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = "off"
}

# ---------------------------------------------------------------
# Database
# ---------------------------------------------------------------
resource "azurerm_postgresql_flexible_server_database" "this" {
  name      = var.db_name
  server_id = azurerm_postgresql_flexible_server.this.id
  collation = "en_US.utf8"
  charset   = "UTF8"
}
