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
