##############################################################
# modules/appgw/outputs.tf
##############################################################
output "public_ip" {
  description = "Application Gateway public IP"
  value       = azurerm_public_ip.this.ip_address
}

output "appgw_id" {
  description = "Application Gateway resource ID"
  value       = azurerm_application_gateway.this.id
}
