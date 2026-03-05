variable "backend_name" {
  description = "Name of the backend Container App"
  type        = string
}

variable "frontend_name" {
  description = "Name of the frontend Container App"
  type        = string
}

variable "postgres_name" {
  description = "Name of the postgres Container App"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "container_app_environment_id" {
  description = "Resource ID of the Container App Environment"
  type        = string
}

variable "managed_identity_id" {
  description = "Resource ID of the user-assigned managed identity"
  type        = string
}

variable "acr_login_server" {
  description = "Login server URL of the Azure Container Registry (e.g. myacr.azurecr.io)"
  type        = string
}

variable "backend_image" {
  description = "Image path within ACR for the backend (e.g. ethan-campbell/team1-back-app:latest)"
  type        = string
}

variable "frontend_image" {
  description = "Image path within ACR for the frontend (e.g. ethan-campbell/team1-front-app:latest)"
  type        = string
}

variable "key_vault_uri" {
  description = "URI of the Key Vault used for secrets (must end with /)"
  type        = string
}

variable "env_default_domain" {
  description = "Default domain of the Container App Environment — used to construct app URLs"
  type        = string
}

variable "enable_job_applications" {
  description = "Feature flag: enable job applications"
  type        = string
  default     = "false"
}

variable "enable_add_job_role" {
  description = "Feature flag: enable adding job roles"
  type        = string
  default     = "false"
}
