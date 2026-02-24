##############################################################
# outputs.tf – All hub resource outputs
##############################################################

output "resource_group_name" {
  description = "Hub Resource Group name"
  value       = local.rg_name
}

output "hub_vnet_id" {
  description = "Hub VNet resource ID (null if not deployed)"
  value       = try(module.vnet[0].vnet_id, null)
}

output "hub_vnet_name" {
  description = "Hub VNet name (null if not deployed)"
  value       = try(module.vnet[0].vnet_name, null)
}

output "hub_subnet_ids" {
  description = "Map of logical subnet key → subnet ID"
  value       = local.subnet_ids
}

output "firewall_private_ip" {
  description = "Azure Firewall private IP (null if not deployed)"
  value       = var.deploy_firewall ? try(module.firewall[0].private_ip, null) : null
}

output "firewall_public_ip" {
  description = "Azure Firewall public IP (null if not deployed)"
  value       = try(module.firewall[0].public_ip, null)
}

output "appgw_public_ip" {
  description = "Application Gateway public IP (null if not deployed)"
  value       = try(module.appgw[0].public_ip, null)
}

output "nat_gateway_public_ip" {
  description = "NAT Gateway public IP (null if not deployed)"
  value       = try(module.nat_gateway[0].public_ip, null)
}

output "internal_lb_ip" {
  description = "Internal LB private IP (null if not deployed)"
  value       = try(module.load_balancer[0].internal_lb_ip, null)
}

output "external_lb_ip" {
  description = "External LB public IP (null if not deployed)"
  value       = try(module.load_balancer[0].external_lb_ip, null)
}

output "bastion_public_ip" {
  description = "Bastion public IP (null if not deployed)"
  value       = try(module.bastion[0].public_ip, null)
}
