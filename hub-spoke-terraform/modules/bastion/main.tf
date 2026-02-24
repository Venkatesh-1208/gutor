##############################################################
# modules/bastion/main.tf
# Azure Bastion Host + Public IP
##############################################################
resource "azurerm_public_ip" "this" {
  name                = var.pip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_bastion_host" "this" {
  name                = var.bastion_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                 = "bastion-ipconfig"
    subnet_id            = var.bastion_subnet_id   # Must be AzureBastionSubnet
    public_ip_address_id = azurerm_public_ip.this.id
  }
}
