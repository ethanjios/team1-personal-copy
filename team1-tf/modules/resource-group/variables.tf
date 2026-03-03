variable "name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region to create the resource group in"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the resource group"
  type        = map(string)
  default     = {}
}
