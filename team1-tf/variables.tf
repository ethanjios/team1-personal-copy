variable "subscription_id" {
  description = "Azure subscription ID to deploy resources into"
  type        = string
}

variable "location" {
  description = "Azure region to deploy resources into"
  type        = string
  default     = "uksouth"
}

variable "project" {
  description = "Project name, used to construct resource names"
  type        = string
  default     = "team1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment must be one of: dev, test, prod"
  }
}

# ---------------------------------------------------------------
# ACR — existing shared registry in the Academy subscription
# ---------------------------------------------------------------
variable "acr_name" {
  description = "Name of the existing Azure Container Registry"
  type        = string
  default     = "academyacrj3r5dv"
}

variable "acr_resource_group_name" {
  description = "Resource group that contains the ACR"
  type        = string
  default     = "rg-academy-acr"
}

# ---------------------------------------------------------------
# Container images
# ---------------------------------------------------------------
variable "backend_image" {
  description = "Image path within ACR for the backend (e.g. ethan-campbell/team1-back-app:latest)"
  type        = string
  default     = "ethan-campbell/team1-back-app:latest"
}

variable "frontend_image" {
  description = "Image path within ACR for the frontend (e.g. ethan-campbell/team1-front-app:latest)"
  type        = string
  default     = "ethan-campbell/team1-front-app:latest"
}

variable "postgres_image" {
  description = "Image path within ACR for postgres (e.g. ethan-campbell/team1-postgres-app:latest)"
  type        = string
  default     = "ethan-campbell/team1-postgres-app:latest"
}

# ---------------------------------------------------------------
# Feature flags — toggle application features without redeploying code
# ---------------------------------------------------------------
variable "enable_job_applications" {
  description = "Enable the job applications feature (true/false)"
  type        = string
  default     = "false"
}

variable "enable_add_job_role" {
  description = "Enable the add job role feature (true/false)"
  type        = string
  default     = "false"
}
