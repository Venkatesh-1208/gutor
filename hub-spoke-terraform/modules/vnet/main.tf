##############################################################
# modules/vnet/main.tf
# Creates Hub VNet + all Subnets using for_each
##############################################################
resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  tags                = var.tags
}

# All subnets created from a single map — add/remove subnets
# by editing the 'subnets' map in your .tfvars file only.
# Special Azure-required names (AzureFirewallSubnet,
# AzureBastionSubnet) are set via the 'name' field in the map.
resource "azurerm_subnet" "this" {
  for_each             = var.subnets
  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value.cidr]
}
