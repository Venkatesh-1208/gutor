##############################################################
# modules/hub/main.tf
# Resources: RG, Hub VNet, Subnets (for_each), NSGs,
#            Azure Firewall, NAT Gateway, App Gateway,
#            Internal LB, External LB, Bastion, Route Table
# Optional resources guarded with count = var.deploy_* ? 1 : 0
##############################################################

##############################################################
# Resource Group
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
# Subnets – for_each over the subnets map variable
# Key  = logical name (e.g. "dmz", "bastion")
# name = actual Azure name (fixed for AzureFirewallSubnet etc.)
##############################################################
resource "azurerm_subnet" "hub" {
  for_each             = var.subnets
  name                 = each.value.name
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [each.value.cidr]
}

##############################################################
# Network Security Groups
##############################################################
resource "azurerm_network_security_group" "management" {
  name                = "nsg-${var.resource_group_name}-management"
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
    source_address_prefix      = try(var.subnets["corporate"].cidr, "10.0.6.0/24")
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
    source_address_prefix      = try(var.subnets["corporate"].cidr, "10.0.6.0/24")
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "management" {
  count                     = contains(keys(var.subnets), "management") ? 1 : 0
  subnet_id                 = azurerm_subnet.hub["management"].id
  network_security_group_id = azurerm_network_security_group.management.id
}

resource "azurerm_network_security_group" "private" {
  name                = "nsg-${var.resource_group_name}-private"
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
    source_address_prefix      = try(var.subnets["dmz"].cidr, "10.0.1.0/24")
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
  count                     = contains(keys(var.subnets), "private") ? 1 : 0
  subnet_id                 = azurerm_subnet.hub["private"].id
  network_security_group_id = azurerm_network_security_group.private.id
}

##############################################################
# Azure Firewall  (count = 0 when deploy_firewall = false)
##############################################################
resource "azurerm_public_ip" "firewall" {
  count               = var.deploy_firewall ? 1 : 0
  name                = var.firewall_pip_name
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_firewall_policy" "hub" {
  count               = var.deploy_firewall ? 1 : 0
  name                = var.firewall_policy_name
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  sku                 = var.firewall_sku_tier
  tags                = var.tags
}

resource "azurerm_firewall" "hub" {
  count               = var.deploy_firewall ? 1 : 0
  name                = var.firewall_name
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  sku_name            = var.firewall_sku_name
  sku_tier            = var.firewall_sku_tier
  firewall_policy_id  = azurerm_firewall_policy.hub[0].id
  tags                = var.tags

  ip_configuration {
    name                 = "fw-ipconfig"
    subnet_id            = azurerm_subnet.hub["dmz"].id
    public_ip_address_id = azurerm_public_ip.firewall[0].id
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "hub" {
  count              = var.deploy_firewall ? 1 : 0
  name               = "fwpol-rcg-hub"
  firewall_policy_id = azurerm_firewall_policy.hub[0].id
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

##############################################################
# NAT Gateway  (count = 0 when deploy_nat_gateway = false)
##############################################################
resource "azurerm_public_ip" "natgw" {
  count               = var.deploy_nat_gateway ? 1 : 0
  name                = var.nat_gateway_pip_name
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
  tags                = var.tags
}

resource "azurerm_nat_gateway" "hub" {
  count                   = var.deploy_nat_gateway ? 1 : 0
  name                    = var.nat_gateway_name
  location                = azurerm_resource_group.hub.location
  resource_group_name     = azurerm_resource_group.hub.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
  tags                    = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "hub" {
  count                = var.deploy_nat_gateway ? 1 : 0
  nat_gateway_id       = azurerm_nat_gateway.hub[0].id
  public_ip_address_id = azurerm_public_ip.natgw[0].id
}

resource "azurerm_subnet_nat_gateway_association" "natgw" {
  count          = var.deploy_nat_gateway && contains(keys(var.subnets), "natgw") ? 1 : 0
  subnet_id      = azurerm_subnet.hub["natgw"].id
  nat_gateway_id = azurerm_nat_gateway.hub[0].id
}

##############################################################
# Application Gateway  (count = 0 when deploy_appgw = false)
##############################################################
resource "azurerm_public_ip" "appgw" {
  count               = var.deploy_appgw ? 1 : 0
  name                = var.appgw_pip_name
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

locals {
  appgw_backend_pool_name         = "agwbp-hub"
  appgw_frontend_port_name        = "agwfp-hub"
  appgw_frontend_ip_config_name   = "agwfeip-hub"
  appgw_http_setting_name         = "agwhs-hub"
  appgw_listener_name             = "agwl-hub"
  appgw_request_routing_rule_name = "agwrr-hub"
}

resource "azurerm_application_gateway" "hub" {
  count               = var.deploy_appgw ? 1 : 0
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
    subnet_id = azurerm_subnet.hub["appgw"].id
  }

  frontend_port {
    name = local.appgw_frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.appgw_frontend_ip_config_name
    public_ip_address_id = azurerm_public_ip.appgw[0].id
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
# Internal Load Balancer  (count = 0 when deploy_internal_lb = false)
##############################################################
resource "azurerm_lb" "internal" {
  count               = var.deploy_internal_lb ? 1 : 0
  name                = var.internal_lb_name
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  sku                 = "Standard"
  tags                = var.tags

  frontend_ip_configuration {
    name                          = "lb-internal-feip"
    subnet_id                     = azurerm_subnet.hub["private"].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb_backend_address_pool" "internal" {
  count           = var.deploy_internal_lb ? 1 : 0
  loadbalancer_id = azurerm_lb.internal[0].id
  name            = "lb-internal-bep"
}

resource "azurerm_lb_probe" "internal" {
  count           = var.deploy_internal_lb ? 1 : 0
  loadbalancer_id = azurerm_lb.internal[0].id
  name            = "lb-probe-http"
  port            = 80
}

resource "azurerm_lb_rule" "internal" {
  count                          = var.deploy_internal_lb ? 1 : 0
  loadbalancer_id                = azurerm_lb.internal[0].id
  name                           = "lb-rule-http"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "lb-internal-feip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.internal[0].id]
  probe_id                       = azurerm_lb_probe.internal[0].id
}

##############################################################
# External Load Balancer  (count = 0 when deploy_external_lb = false)
##############################################################
resource "azurerm_public_ip" "external_lb" {
  count               = var.deploy_external_lb ? 1 : 0
  name                = var.external_lb_pip_name
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_lb" "external" {
  count               = var.deploy_external_lb ? 1 : 0
  name                = var.external_lb_name
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  sku                 = "Standard"
  tags                = var.tags

  frontend_ip_configuration {
    name                 = "lb-external-feip"
    public_ip_address_id = azurerm_public_ip.external_lb[0].id
  }
}

resource "azurerm_lb_backend_address_pool" "external" {
  count           = var.deploy_external_lb ? 1 : 0
  loadbalancer_id = azurerm_lb.external[0].id
  name            = "lb-external-bep"
}

resource "azurerm_lb_probe" "external" {
  count           = var.deploy_external_lb ? 1 : 0
  loadbalancer_id = azurerm_lb.external[0].id
  name            = "lb-probe-https"
  port            = 443
}

resource "azurerm_lb_rule" "external" {
  count                          = var.deploy_external_lb ? 1 : 0
  loadbalancer_id                = azurerm_lb.external[0].id
  name                           = "lb-rule-https"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "lb-external-feip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.external[0].id]
  probe_id                       = azurerm_lb_probe.external[0].id
}

##############################################################
# Azure Bastion  (count = 0 when deploy_bastion = false)
##############################################################
resource "azurerm_public_ip" "bastion" {
  count               = var.deploy_bastion ? 1 : 0
  name                = var.bastion_pip_name
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_bastion_host" "hub" {
  count               = var.deploy_bastion ? 1 : 0
  name                = var.bastion_name
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  tags                = var.tags

  ip_configuration {
    name                 = "bastion-ipconfig"
    subnet_id            = azurerm_subnet.hub["bastion"].id
    public_ip_address_id = azurerm_public_ip.bastion[0].id
  }
}

##############################################################
# Route Table – force traffic through Azure Firewall
# Only associated when Firewall is deployed
##############################################################
resource "azurerm_route_table" "hub" {
  name                          = var.route_table_name
  location                      = azurerm_resource_group.hub.location
  resource_group_name           = azurerm_resource_group.hub.name
  disable_bgp_route_propagation = true
  tags                          = var.tags

  dynamic "route" {
    for_each = var.deploy_firewall ? [1] : []
    content {
      name                   = "default-via-firewall"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = azurerm_firewall.hub[0].ip_configuration[0].private_ip_address
    }
  }
}

resource "azurerm_subnet_route_table_association" "private" {
  count          = contains(keys(var.subnets), "private") ? 1 : 0
  subnet_id      = azurerm_subnet.hub["private"].id
  route_table_id = azurerm_route_table.hub.id
}

resource "azurerm_subnet_route_table_association" "management" {
  count          = contains(keys(var.subnets), "management") ? 1 : 0
  subnet_id      = azurerm_subnet.hub["management"].id
  route_table_id = azurerm_route_table.hub.id
}

resource "azurerm_subnet_route_table_association" "corporate" {
  count          = contains(keys(var.subnets), "corporate") ? 1 : 0
  subnet_id      = azurerm_subnet.hub["corporate"].id
  route_table_id = azurerm_route_table.hub.id
}
