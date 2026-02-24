##############################################################
# modules/firewall/outputs.tf
##############################################################
output "private_ip" {
  description = "Firewall private IP (used by Route Table UDR)"
  value       = azurerm_firewall.this.ip_configuration[0].private_ip_address
}

output "public_ip" {
  description = "Firewall public IP"
  value       = azurerm_public_ip.this.ip_address
}

output "firewall_id" {
  description = "Firewall resource ID"
  value       = azurerm_firewall.this.id
}

output "policy_id" {
  description = "Firewall Policy resource ID"
  value       = azurerm_firewall_policy.this.id
}
