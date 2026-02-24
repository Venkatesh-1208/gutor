##############################################################
# modules/bastion/outputs.tf
##############################################################
output "public_ip" {
  description = "Bastion public IP"
  value       = azurerm_public_ip.this.ip_address
}

output "bastion_id" {
  description = "Bastion host resource ID"
  value       = azurerm_bastion_host.this.id
}
