##############################################################
# modules/load_balancer/outputs.tf
##############################################################
output "internal_lb_ip" {
  description = "Internal LB private frontend IP (null if not deployed)"
  value       = try(azurerm_lb.internal[0].frontend_ip_configuration[0].private_ip_address, null)
}

output "external_lb_ip" {
  description = "External LB public IP (null if not deployed)"
  value       = try(azurerm_public_ip.external[0].ip_address, null)
}

output "internal_lb_id" {
  description = "Internal LB resource ID (null if not deployed)"
  value       = try(azurerm_lb.internal[0].id, null)
}

output "external_lb_id" {
  description = "External LB resource ID (null if not deployed)"
  value       = try(azurerm_lb.external[0].id, null)
}
