##############################################################
# environments/prod/prod.tfvars
# Usage: terraform plan -var-file="environments/prod/prod.tfvars"
##############################################################

hub_subscription_id = "00000000-0000-0000-0000-000000000001"  # ← Replace with Prod Sub ID
location            = "eastus"

tags = {
  Environment  = "Production"
  ManagedBy    = "Terraform"
  Architecture = "Hub"
  CostCenter   = "IT-Prod"
}

# ── Resource Group ───────────────────────────────────────────
deploy_resource_group = true
resource_group_name   = "rg-hub-network-prod"

# ── Virtual Network ──────────────────────────────────────────
deploy_vnet            = true
hub_vnet_name          = "vnet-hub-prod"
hub_vnet_address_space = ["10.0.0.0/16"]

subnets = {
  management = { name = "snet-management-prod",    cidr = "10.0.0.0/24" }
  dmz        = { name = "AzureFirewallSubnet",     cidr = "10.0.1.0/24" }
  private    = { name = "snet-private-prod",       cidr = "10.0.2.0/24" }
  public     = { name = "snet-public-prod",        cidr = "10.0.3.0/24" }
  appgw      = { name = "snet-appgateway-prod",    cidr = "10.0.4.0/24" }
  natgw      = { name = "snet-natgateway-prod",    cidr = "10.0.5.0/24" }
  corporate  = { name = "snet-corporate-prod",     cidr = "10.0.6.0/24" }
  bastion    = { name = "AzureBastionSubnet",      cidr = "10.0.7.0/26" }
}

# ── NSG ──────────────────────────────────────────────────────
deploy_nsg          = true
nsg_management_name = "nsg-management-prod"
nsg_private_name    = "nsg-private-prod"

# ── Route Table ──────────────────────────────────────────────
deploy_route_table = true
route_table_name   = "rt-hub-prod"

# ── Azure Firewall ───────────────────────────────────────────
deploy_firewall      = true
firewall_name        = "fw-hub-prod"
firewall_pip_name    = "pip-fw-hub-prod"
firewall_policy_name = "fwpol-hub-prod"
firewall_sku_name    = "AZFW_VNet"
firewall_sku_tier    = "Premium"     # Premium in Prod for IDPS + TLS inspection

# ── NAT Gateway ──────────────────────────────────────────────
deploy_nat_gateway   = true
nat_gateway_name     = "natgw-hub-prod"
nat_gateway_pip_name = "pip-natgw-hub-prod"

# ── Application Gateway ──────────────────────────────────────
deploy_appgw   = true
appgw_name     = "agw-hub-prod"
appgw_pip_name = "pip-agw-hub-prod"
appgw_sku_name = "WAF_v2"
appgw_sku_tier = "WAF_v2"
appgw_capacity = 2       # 2 instances for HA in Prod

# ── Load Balancers ───────────────────────────────────────────
deploy_internal_lb   = true
internal_lb_name     = "lb-internal-hub-prod"
deploy_external_lb   = true
external_lb_name     = "lb-external-hub-prod"
external_lb_pip_name = "pip-lb-external-hub-prod"

# ── Azure Bastion ────────────────────────────────────────────
deploy_bastion   = true
bastion_name     = "bas-hub-prod"
bastion_pip_name = "pip-bastion-hub-prod"
