##############################################################
# environments/test/test.tfvars
# Usage: terraform plan -var-file="environments/test/test.tfvars"
##############################################################

hub_subscription_id = "00000000-0000-0000-0000-000000000002"  # ← Replace with Test Sub ID
location            = "eastus"

tags = {
  Environment  = "Test"
  ManagedBy    = "Terraform"
  Architecture = "Hub"
  CostCenter   = "IT-Test"
}

# ── Resource Group ───────────────────────────────────────────
deploy_resource_group = true
resource_group_name   = "rg-hub-network-test"

# ── Virtual Network ──────────────────────────────────────────
deploy_vnet            = true
hub_vnet_name          = "vnet-hub-test"
hub_vnet_address_space = ["10.10.0.0/16"]

subnets = {
  management = { name = "snet-management-test",    cidr = "10.10.0.0/24" }
  dmz        = { name = "AzureFirewallSubnet",     cidr = "10.10.1.0/24" }
  private    = { name = "snet-private-test",       cidr = "10.10.2.0/24" }
  public     = { name = "snet-public-test",        cidr = "10.10.3.0/24" }
  appgw      = { name = "snet-appgateway-test",    cidr = "10.10.4.0/24" }
  natgw      = { name = "snet-natgateway-test",    cidr = "10.10.5.0/24" }
  corporate  = { name = "snet-corporate-test",     cidr = "10.10.6.0/24" }
  bastion    = { name = "AzureBastionSubnet",      cidr = "10.10.7.0/26" }
}

# ── NSG ──────────────────────────────────────────────────────
deploy_nsg          = true
nsg_management_name = "nsg-management-test"
nsg_private_name    = "nsg-private-test"

# ── Route Table ──────────────────────────────────────────────
deploy_route_table = true
route_table_name   = "rt-hub-test"

# ── Azure Firewall ───────────────────────────────────────────
deploy_firewall      = true
firewall_name        = "fw-hub-test"
firewall_pip_name    = "pip-fw-hub-test"
firewall_policy_name = "fwpol-hub-test"
firewall_sku_name    = "AZFW_VNet"
firewall_sku_tier    = "Standard"

# ── NAT Gateway ──────────────────────────────────────────────
deploy_nat_gateway   = true
nat_gateway_name     = "natgw-hub-test"
nat_gateway_pip_name = "pip-natgw-hub-test"

# ── Application Gateway ──────────────────────────────────────
deploy_appgw   = true
appgw_name     = "agw-hub-test"
appgw_pip_name = "pip-agw-hub-test"
appgw_sku_name = "WAF_v2"
appgw_sku_tier = "WAF_v2"
appgw_capacity = 1       # Minimum for Test (saves cost)

# ── Load Balancers ───────────────────────────────────────────
deploy_internal_lb   = true
internal_lb_name     = "lb-internal-hub-test"
deploy_external_lb   = false   # Not needed in Test
external_lb_name     = "lb-external-hub-test"
external_lb_pip_name = "pip-lb-external-hub-test"

# ── Azure Bastion ────────────────────────────────────────────
deploy_bastion   = false        # Skip Bastion in Test (saves ~$140/mo)
bastion_name     = "bas-hub-test"
bastion_pip_name = "pip-bastion-hub-test"
