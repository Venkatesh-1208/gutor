##############################################################
# modules/hub/outputs.tf
# Subnet IDs exported as a map; optional resources use try()
# so outputs gracefully return null when count = 0.
##############################################################

output "resource_group_name" {
  description = "Hub resource group name"
  value       = azurerm_resource_group.hub.name
}

output "vnet_id" {
  description = "Hub VNet resource ID"
  value       = azurerm_virtual_network.hub.id
}

output "vnet_name" {
  description = "Hub VNet name"
  value       = azurerm_virtual_network.hub.name
}

# All subnet IDs as a map: logical key → subnet ID
output "subnet_ids" {
  description = "Map of logical subnet key to Azure Subnet resource ID"
  value       = { for k, s in azurerm_subnet.hub : k => s.id }
}

# All subnet names as a map: logical key → subnet name
output "subnet_names" {
  description = "Map of logical subnet key to Azure Subnet name"
  value       = { for k, s in azurerm_subnet.hub : k => s.name }
}

# ── Optional resource outputs (null when not deployed) ────────
output "firewall_private_ip" {
  description = "Private IP of Azure Firewall (null if not deployed)"
  value       = try(azurerm_firewall.hub[0].ip_configuration[0].private_ip_address, null)
}

output "firewall_public_ip" {
  description = "Public IP of Azure Firewall (null if not deployed)"
  value       = try(azurerm_public_ip.firewall[0].ip_address, null)
}

output "appgw_public_ip" {
  description = "Public IP of Application Gateway (null if not deployed)"
  value       = try(azurerm_public_ip.appgw[0].ip_address, null)
}

output "nat_gateway_public_ip" {
  description = "Public IP of NAT Gateway (null if not deployed)"
  value       = try(azurerm_public_ip.natgw[0].ip_address, null)
}

output "internal_lb_ip" {
  description = "Frontend IP of Internal Load Balancer (null if not deployed)"
  value       = try(azurerm_lb.internal[0].frontend_ip_configuration[0].private_ip_address, null)
}

output "external_lb_ip" {
  description = "Public IP of External Load Balancer (null if not deployed)"
  value       = try(azurerm_public_ip.external_lb[0].ip_address, null)
}

output "bastion_public_ip" {
  description = "Public IP of Azure Bastion (null if not deployed)"
  value       = try(azurerm_public_ip.bastion[0].ip_address, null)
}

output "route_table_id" {
  description = "ID of the Hub Route Table"
  value       = azurerm_route_table.hub.id
}
