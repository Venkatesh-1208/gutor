##############################################################
# outputs.tf – Hub resource IDs and connection info
##############################################################

output "hub_vnet_id" {
  description = "Hub VNet resource ID"
  value       = module.hub.vnet_id
}

output "hub_vnet_name" {
  description = "Hub VNet name"
  value       = module.hub.vnet_name
}

output "hub_resource_group_name" {
  description = "Hub resource group name"
  value       = module.hub.resource_group_name
}

output "azure_firewall_private_ip" {
  description = "Private IP of the Azure Firewall"
  value       = module.hub.firewall_private_ip
}

output "azure_firewall_public_ip" {
  description = "Public IP of the Azure Firewall"
  value       = module.hub.firewall_public_ip
}

output "app_gateway_public_ip" {
  description = "Public IP of the Application Gateway"
  value       = module.hub.appgw_public_ip
}

output "nat_gateway_public_ip" {
  description = "Public IP of the NAT Gateway"
  value       = module.hub.nat_gateway_public_ip
}

output "internal_load_balancer_ip" {
  description = "Frontend IP of the Internal Load Balancer"
  value       = module.hub.internal_lb_ip
}

output "external_load_balancer_ip" {
  description = "Public IP of the External Load Balancer"
  value       = module.hub.external_lb_ip
}
