output "vnet_id" {
  value = azurerm_virtual_network.hub.id
}

output "vnet_name" {
  value = azurerm_virtual_network.hub.name
}

output "resource_group_name" {
  value = azurerm_resource_group.hub.name
}

output "firewall_private_ip" {
  value = azurerm_firewall.hub.ip_configuration[0].private_ip_address
}

output "firewall_public_ip" {
  value = azurerm_public_ip.firewall.ip_address
}

output "appgw_public_ip" {
  value = azurerm_public_ip.appgw.ip_address
}

output "nat_gateway_public_ip" {
  value = azurerm_public_ip.natgw.ip_address
}

output "internal_lb_ip" {
  value = azurerm_lb.internal.frontend_ip_configuration[0].private_ip_address
}

output "external_lb_ip" {
  value = azurerm_public_ip.external_lb.ip_address
}

output "management_subnet_id" {
  value = azurerm_subnet.management.id
}

output "private_subnet_id" {
  value = azurerm_subnet.private.id
}

output "public_subnet_id" {
  value = azurerm_subnet.public.id
}

output "corporate_subnet_id" {
  value = azurerm_subnet.corporate.id
}
