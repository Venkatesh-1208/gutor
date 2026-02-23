##############################################################
# modules/peering/main.tf
# Bidirectional VNet Peering between Hub and a Spoke
##############################################################

# Hub → Spoke peering (created in Hub subscription)
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  provider = azurerm.local

  name                         = "peer-hub-to-${var.remote_vnet_name}"
  resource_group_name          = var.local_resource_group
  virtual_network_name         = var.local_vnet_name
  remote_virtual_network_id    = var.remote_vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = var.allow_gateway_transit
  use_remote_gateways          = false
}

# Spoke → Hub peering (created in Spoke subscription)
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  provider = azurerm.remote

  name                         = "peer-${var.remote_vnet_name}-to-hub"
  resource_group_name          = var.remote_resource_group
  virtual_network_name         = var.remote_vnet_name
  remote_virtual_network_id    = var.local_vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = var.use_remote_gateways
}
