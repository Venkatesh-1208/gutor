##############################################################
# modules/resource_group/outputs.tf
##############################################################
output "name" {
  description = "Resource Group name"
  value       = azurerm_resource_group.this.name
}

output "id" {
  description = "Resource Group resource ID"
  value       = azurerm_resource_group.this.id
}

output "location" {
  description = "Resource Group location"
  value       = azurerm_resource_group.this.location
}
