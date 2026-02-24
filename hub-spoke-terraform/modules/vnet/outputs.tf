##############################################################
# modules/vnet/outputs.tf
##############################################################
output "vnet_id" {
  description = "VNet resource ID"
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "VNet name"
  value       = azurerm_virtual_network.this.name
}

# Map of logical key → subnet ID (e.g. "dmz" → "/subscriptions/.../subnets/AzureFirewallSubnet")
output "subnet_ids" {
  description = "Map of logical subnet key to subnet resource ID"
  value       = { for k, s in azurerm_subnet.this : k => s.id }
}

# Map of logical key → subnet CIDR
output "subnet_cidrs" {
  description = "Map of logical subnet key to address prefix"
  value       = { for k, s in azurerm_subnet.this : k => s.address_prefixes[0] }
}
