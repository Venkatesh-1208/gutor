##############################################################
# modules/nat_gateway/outputs.tf
##############################################################
output "public_ip" {
  description = "NAT Gateway public IP address"
  value       = azurerm_public_ip.this.ip_address
}

output "nat_gateway_id" {
  description = "NAT Gateway resource ID"
  value       = azurerm_nat_gateway.this.id
}
