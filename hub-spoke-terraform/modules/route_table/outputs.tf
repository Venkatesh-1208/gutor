##############################################################
# modules/route_table/outputs.tf
##############################################################
output "route_table_id" {
  description = "Route Table resource ID"
  value       = azurerm_route_table.this.id
}

output "route_table_name" {
  description = "Route Table name"
  value       = azurerm_route_table.this.name
}
