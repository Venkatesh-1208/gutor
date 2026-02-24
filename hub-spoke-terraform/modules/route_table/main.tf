##############################################################
# modules/route_table/main.tf
# Creates a Route Table that sends all traffic via the Firewall,
# then associates it with private, management, and corporate subnets.
##############################################################
resource "azurerm_route_table" "this" {
  name                          = var.route_table_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = true
  tags                          = var.tags

  # Route only created when a Firewall private IP is provided
  dynamic "route" {
    for_each = var.firewall_private_ip != "" ? [1] : []
    content {
      name                   = "default-via-firewall"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = var.firewall_private_ip
    }
  }
}

resource "azurerm_subnet_route_table_association" "private" {
  count          = var.private_subnet_id != "" ? 1 : 0
  subnet_id      = var.private_subnet_id
  route_table_id = azurerm_route_table.this.id
}

resource "azurerm_subnet_route_table_association" "management" {
  count          = var.management_subnet_id != "" ? 1 : 0
  subnet_id      = var.management_subnet_id
  route_table_id = azurerm_route_table.this.id
}

resource "azurerm_subnet_route_table_association" "corporate" {
  count          = var.corporate_subnet_id != "" ? 1 : 0
  subnet_id      = var.corporate_subnet_id
  route_table_id = azurerm_route_table.this.id
}
