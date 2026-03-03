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
