##############################################################
# modules/load_balancer/main.tf
# Internal LB (private) + External LB (public)
# Each controlled by its own deploy_* variable.
##############################################################

# ── Internal Load Balancer ───────────────────────────────────
resource "azurerm_lb" "internal" {
  count               = var.deploy_internal_lb ? 1 : 0
  name                = var.internal_lb_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  tags                = var.tags

  frontend_ip_configuration {
    name                          = "lb-internal-feip"
    subnet_id                     = var.private_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb_backend_address_pool" "internal" {
  count           = var.deploy_internal_lb ? 1 : 0
  loadbalancer_id = azurerm_lb.internal[0].id
  name            = "${var.internal_lb_name}-bep"
}

resource "azurerm_lb_probe" "internal" {
  count           = var.deploy_internal_lb ? 1 : 0
  loadbalancer_id = azurerm_lb.internal[0].id
  name            = "${var.internal_lb_name}-probe"
  port            = 80
}

resource "azurerm_lb_rule" "internal" {
  count                          = var.deploy_internal_lb ? 1 : 0
  loadbalancer_id                = azurerm_lb.internal[0].id
  name                           = "${var.internal_lb_name}-rule-http"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "lb-internal-feip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.internal[0].id]
  probe_id                       = azurerm_lb_probe.internal[0].id
}

# ── External Load Balancer ───────────────────────────────────
resource "azurerm_public_ip" "external" {
  count               = var.deploy_external_lb ? 1 : 0
  name                = var.external_lb_pip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_lb" "external" {
  count               = var.deploy_external_lb ? 1 : 0
  name                = var.external_lb_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  tags                = var.tags

  frontend_ip_configuration {
    name                 = "lb-external-feip"
    public_ip_address_id = azurerm_public_ip.external[0].id
  }
}

resource "azurerm_lb_backend_address_pool" "external" {
  count           = var.deploy_external_lb ? 1 : 0
  loadbalancer_id = azurerm_lb.external[0].id
  name            = "${var.external_lb_name}-bep"
}

resource "azurerm_lb_probe" "external" {
  count           = var.deploy_external_lb ? 1 : 0
  loadbalancer_id = azurerm_lb.external[0].id
  name            = "${var.external_lb_name}-probe"
  port            = 443
}

resource "azurerm_lb_rule" "external" {
  count                          = var.deploy_external_lb ? 1 : 0
  loadbalancer_id                = azurerm_lb.external[0].id
  name                           = "${var.external_lb_name}-rule-https"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "lb-external-feip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.external[0].id]
  probe_id                       = azurerm_lb_probe.external[0].id
}
