##############################################################
# modules/nsg/main.tf
# Creates NSGs for Management and Private subnets and
# associates them. Source CIDRs come from the subnets map.
##############################################################
resource "azurerm_network_security_group" "management" {
  name                = var.nsg_management_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "AllowRDPFromCorporate"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = var.corporate_subnet_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSSHFromCorporate"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.corporate_subnet_cidr
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "private" {
  name                = var.nsg_private_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "AllowFromFirewall"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.dmz_subnet_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyInternetInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

# Subnet associations
resource "azurerm_subnet_network_security_group_association" "management" {
  subnet_id                 = var.management_subnet_id
  network_security_group_id = azurerm_network_security_group.management.id
}

resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = var.private_subnet_id
  network_security_group_id = azurerm_network_security_group.private.id
}
