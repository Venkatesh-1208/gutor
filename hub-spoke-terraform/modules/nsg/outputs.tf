##############################################################
# modules/nsg/outputs.tf
##############################################################
output "management_nsg_id" {
  description = "Management NSG resource ID"
  value       = azurerm_network_security_group.management.id
}

output "private_nsg_id" {
  description = "Private NSG resource ID"
  value       = azurerm_network_security_group.private.id
}
