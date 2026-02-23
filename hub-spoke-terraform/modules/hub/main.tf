##############################################################
# modules/hub/main.tf
# Resources: Resource Group, Hub VNet, 7 Subnets, NSGs,
#            Azure Firewall (DMZ), NAT Gateway, App Gateway,
#            Internal LB, External LB, Bastion (Management)
##############################################################

resource "azurerm_resource_group" "hub" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

##############################################################
# Hub Virtual Network
##############################################################
resource "azurerm_virtual_network" "hub" {
  name                = var.hub_vnet_name
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = var.hub_vnet_address_space
  tags                = var.tags
}

##############################################################
# Subnets
##############################################################
resource "azurerm_subnet" "management" {
  name                 = "snet-management"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.management_subnet_cidr]
}

# DMZ subnet – must be named AzureFirewallSubnet
resource "azurerm_subnet" "dmz" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.dmz_subnet_cidr]
}

resource "azurerm_subnet" "private" {
  name                 = "snet-private"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.private_subnet_cidr]
}

resource "azurerm_subnet" "public" {
  name                 = "snet-public"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.public_subnet_cidr]
}

resource "azurerm_subnet" "appgw" {
  name                 = "snet-appgateway"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.appgw_subnet_cidr]
}

resource "azurerm_subnet" "natgw" {
  name                 = "snet-natgateway"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.natgw_subnet_cidr]
}

resource "azurerm_subnet" "corporate" {
  name                 = "snet-corporate"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.corporate_subnet_cidr]
}

# Bastion subnet – required name
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.bastion_subnet_cidr]
}

##############################################################
# Network Security Groups
##############################################################
resource "azurerm_network_security_group" "management" {
  name                = "nsg-management"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
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

resource "azurerm_subnet_network_security_group_association" "management" {
  subnet_id                 = azurerm_subnet.management.id
  network_security_group_id = azurerm_network_security_group.management.id
}

resource "azurerm_network_security_group" "private" {
  name                = "nsg-private"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
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

resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.private.id
}

##############################################################
# Azure Firewall – in DMZ subnet
##############################################################
resource "azurerm_public_ip" "firewall" {
  name                = "pip-fw-hub"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_firewall_policy" "hub" {
  name                = "fwpol-hub"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  sku                 = var.firewall_sku_tier
  tags                = var.tags
}

resource "azurerm_firewall" "hub" {
  name                = var.firewall_name
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  sku_name            = var.firewall_sku_name
  sku_tier            = var.firewall_sku_tier
  firewall_policy_id  = azurerm_firewall_policy.hub.id
  tags                = var.tags

  ip_configuration {
    name                 = "fw-ipconfig"
    subnet_id            = azurerm_subnet.dmz.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }
}

##############################################################
# Firewall Policy Rule Collections (example rules)
##############################################################
resource "azurerm_firewall_policy_rule_collection_group" "hub" {
  name               = "fwpol-rcg-hub"
  firewall_policy_id = azurerm_firewall_policy.hub.id
  priority           = 100

  network_rule_collection {
    name     = "allow-spoke-to-spoke"
    priority = 100
    action   = "Allow"

    rule {
      name                  = "spoke-to-spoke"
      protocols             = ["Any"]
      source_addresses      = ["10.1.0.0/8"]
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

##############################################################
# NAT Gateway
##############################################################
resource "azurerm_public_ip" "natgw" {
  name                = "pip-natgw-hub"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
  tags                = var.tags
}

resource "azurerm_nat_gateway" "hub" {
  name                    = "natgw-hub"
  location                = azurerm_resource_group.hub.location
  resource_group_name     = azurerm_resource_group.hub.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
  tags                    = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "hub" {
  nat_gateway_id       = azurerm_nat_gateway.hub.id
  public_ip_address_id = azurerm_public_ip.natgw.id
}

resource "azurerm_subnet_nat_gateway_association" "natgw" {
  subnet_id      = azurerm_subnet.natgw.id
  nat_gateway_id = azurerm_nat_gateway.hub.id
}

##############################################################
# Application Gateway (WAF v2)
##############################################################
resource "azurerm_public_ip" "appgw" {
  name                = "pip-agw-hub"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

locals {
  appgw_backend_pool_name            = "agwbp-hub"
  appgw_frontend_port_name           = "agwfp-hub"
  appgw_frontend_ip_config_name      = "agwfeip-hub"
  appgw_http_setting_name            = "agwhs-hub"
  appgw_listener_name                = "agwl-hub"
  appgw_request_routing_rule_name    = "agwrr-hub"
}

resource "azurerm_application_gateway" "hub" {
  name                = var.appgw_name
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  tags                = var.tags

  sku {
    name     = var.appgw_sku_name
    tier     = var.appgw_sku_tier
    capacity = var.appgw_capacity
  }

  gateway_ip_configuration {
    name      = "agw-ip-config"
    subnet_id = azurerm_subnet.appgw.id
  }

  frontend_port {
    name = local.appgw_frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.appgw_frontend_ip_config_name
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  backend_address_pool {
    name = local.appgw_backend_pool_name
  }

  backend_http_settings {
    name                  = local.appgw_http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.appgw_listener_name
    frontend_ip_configuration_name = local.appgw_frontend_ip_config_name
    frontend_port_name             = local.appgw_frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.appgw_request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.appgw_listener_name
    backend_address_pool_name  = local.appgw_backend_pool_name
    backend_http_settings_name = local.appgw_http_setting_name
    priority                   = 1
  }

  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }
}

##############################################################
# Internal Load Balancer – Private subnet
##############################################################
resource "azurerm_lb" "internal" {
  name                = "lb-internal-hub"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  sku                 = "Standard"
  tags                = var.tags

  frontend_ip_configuration {
    name                          = "lb-internal-feip"
    subnet_id                     = azurerm_subnet.private.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb_backend_address_pool" "internal" {
  loadbalancer_id = azurerm_lb.internal.id
  name            = "lb-internal-bep"
}

resource "azurerm_lb_probe" "internal" {
  loadbalancer_id = azurerm_lb.internal.id
  name            = "lb-probe-http"
  port            = 80
}

resource "azurerm_lb_rule" "internal" {
  loadbalancer_id                = azurerm_lb.internal.id
  name                           = "lb-rule-http"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "lb-internal-feip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.internal.id]
  probe_id                       = azurerm_lb_probe.internal.id
}

##############################################################
# External Load Balancer – Public subnet
##############################################################
resource "azurerm_public_ip" "external_lb" {
  name                = "pip-lb-external-hub"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_lb" "external" {
  name                = "lb-external-hub"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  sku                 = "Standard"
  tags                = var.tags

  frontend_ip_configuration {
    name                 = "lb-external-feip"
    public_ip_address_id = azurerm_public_ip.external_lb.id
  }
}

resource "azurerm_lb_backend_address_pool" "external" {
  loadbalancer_id = azurerm_lb.external.id
  name            = "lb-external-bep"
}

resource "azurerm_lb_probe" "external" {
  loadbalancer_id = azurerm_lb.external.id
  name            = "lb-probe-https"
  port            = 443
}

resource "azurerm_lb_rule" "external" {
  loadbalancer_id                = azurerm_lb.external.id
  name                           = "lb-rule-https"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "lb-external-feip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.external.id]
  probe_id                       = azurerm_lb_probe.external.id
}

##############################################################
# Azure Bastion – Management subnet
##############################################################
resource "azurerm_public_ip" "bastion" {
  name                = "pip-bastion-hub"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_bastion_host" "hub" {
  name                = "bas-hub"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  tags                = var.tags

  ip_configuration {
    name                 = "bastion-ipconfig"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}

##############################################################
# Route Table – force traffic through Azure Firewall
##############################################################
resource "azurerm_route_table" "hub" {
  name                          = "rt-hub"
  location                      = azurerm_resource_group.hub.location
  resource_group_name           = azurerm_resource_group.hub.name
  disable_bgp_route_propagation = true
  tags                          = var.tags

  route {
    name                   = "default-via-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.hub.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "private" {
  subnet_id      = azurerm_subnet.private.id
  route_table_id = azurerm_route_table.hub.id
}

resource "azurerm_subnet_route_table_association" "management" {
  subnet_id      = azurerm_subnet.management.id
  route_table_id = azurerm_route_table.hub.id
}

resource "azurerm_subnet_route_table_association" "corporate" {
  subnet_id      = azurerm_subnet.corporate.id
  route_table_id = azurerm_route_table.hub.id
}
