##############################################################
# modules/firewall/main.tf
# Azure Firewall + Firewall Policy + Public IP
##############################################################
resource "azurerm_public_ip" "this" {
  name                = var.pip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_firewall_policy" "this" {
  name                = var.policy_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku_tier
  tags                = var.tags
}

resource "azurerm_firewall" "this" {
  name                = var.firewall_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name
  sku_tier            = var.sku_tier
  firewall_policy_id  = azurerm_firewall_policy.this.id
  tags                = var.tags

  ip_configuration {
    name                 = "fw-ipconfig"
    subnet_id            = var.dmz_subnet_id    # Must be AzureFirewallSubnet
    public_ip_address_id = azurerm_public_ip.this.id
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "this" {
  name               = "fwpol-rcg-hub"
  firewall_policy_id = azurerm_firewall_policy.this.id
  priority           = 100

  network_rule_collection {
    name     = "allow-hub-internal"
    priority = 100
    action   = "Allow"

    rule {
      name                  = "hub-internal-traffic"
      protocols             = ["Any"]
      source_addresses      = ["10.0.0.0/8"]
      destination_addresses = ["10.0.0.0/8"]
      destination_ports     = ["*"]
    }
  }

  application_rule_collection {
    name     = "allow-internet-http"
    priority = 200
    action   = "Allow"

    rule {
      name             = "allow-web"
      source_addresses = ["10.0.0.0/8"]
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      destination_fqdns = ["*"]
    }
  }
}
