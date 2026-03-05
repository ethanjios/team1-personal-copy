terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-tfstate-ethan-campbell"
    storage_account_name = "ethanctfstate"
    container_name       = "tfstate"
    key                  = "team1.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

locals {
  # Short identifier for resources with strict name-length limits (e.g. Key Vault: max 24 chars)
  short_id = "team1ec"

  tags = {
    environment = var.environment
    project     = var.project
    managed_by  = "terraform"
  }
}

# ---------------------------------------------------------------
# Existing ACR — referenced to get its resource ID and login server
# ---------------------------------------------------------------
data "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.acr_resource_group_name
}

# ---------------------------------------------------------------
# Resource Group
# ---------------------------------------------------------------
module "resource_group" {
  source = "./modules/resource-group"

  name     = "rg-${var.project}-${var.environment}"
  location = var.location

  tags = local.tags
}

# ---------------------------------------------------------------
# Key Vault — secrets are added manually in the portal after creation
# ---------------------------------------------------------------
module "key_vault" {
  source = "./modules/key-vault"

  name                = "kv-${local.short_id}-${var.environment}"
  location            = var.location
  resource_group_name = module.resource_group.name

  tags = local.tags
}

# ---------------------------------------------------------------
# User-Assigned Managed Identity
# Used by Container Apps to pull images from ACR and read secrets from Key Vault
# ---------------------------------------------------------------
module "managed_identity" {
  source = "./modules/managed-identity"

  name                = "id-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = module.resource_group.name

  tags = local.tags
}

# ---------------------------------------------------------------
# Container App Environment (the platform) + Log Analytics workspace
# ---------------------------------------------------------------
module "container_app_environment" {
  source = "./modules/container-app-environment"

  name                = "cae-${var.project}-${var.environment}"
  log_analytics_name  = "law-${var.project}-${var.environment}"
  location            = var.location
  resource_group_name = module.resource_group.name

  tags = local.tags
}

# ---------------------------------------------------------------
# Role assignments for the managed identity
# ---------------------------------------------------------------

# Allow managed identity to pull images from ACR
resource "azurerm_role_assignment" "acr_pull" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = module.managed_identity.principal_id
}

# Allow managed identity to read secrets from Key Vault
resource "azurerm_role_assignment" "kv_secrets_user" {
  scope                = module.key_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.managed_identity.principal_id
}

# ---------------------------------------------------------------
# Container Apps — frontend (public) and backend (internal only)
# depends_on ensures role assignments complete before apps try to
# pull from ACR and read secrets from Key Vault
# ---------------------------------------------------------------
module "container_apps" {
  source = "./modules/container-apps"

  backend_name                 = "back-${local.short_id}-${var.environment}"
  frontend_name                = "front-${local.short_id}-${var.environment}"
  resource_group_name          = module.resource_group.name
  container_app_environment_id = module.container_app_environment.id
  managed_identity_id          = module.managed_identity.id
  acr_login_server             = data.azurerm_container_registry.acr.login_server
  backend_image                = var.backend_image
  frontend_image               = var.frontend_image
  key_vault_uri                = module.key_vault.vault_uri
  env_default_domain           = module.container_app_environment.default_domain
  enable_job_applications      = var.enable_job_applications
  enable_add_job_role          = var.enable_add_job_role

  depends_on = [
    azurerm_role_assignment.acr_pull,
    azurerm_role_assignment.kv_secrets_user,
  ]
}
