##############################################################
# terraform.tfvars – Hub subscription deployment values
##############################################################

# ── Subscription ───────────────────────────────────────────────
hub_subscription_id = "00000000-0000-0000-0000-000000000001"

# ── Global ────────────────────────────────────────────────────
location = "eastus"

tags = {
  Environment  = "Production"
  ManagedBy    = "Terraform"
  Architecture = "Hub"
  CostCenter   = "IT-Infra"
}

# ── Hub ───────────────────────────────────────────────────────
hub_resource_group_name = "rg-hub-network"
hub_vnet_name           = "vnet-hub"
hub_vnet_address_space  = ["10.0.0.0/16"]

management_subnet_cidr = "10.0.0.0/24"
dmz_subnet_cidr        = "10.0.1.0/24"
private_subnet_cidr    = "10.0.2.0/24"
public_subnet_cidr     = "10.0.3.0/24"
appgw_subnet_cidr      = "10.0.4.0/24"
natgw_subnet_cidr      = "10.0.5.0/24"
corporate_subnet_cidr  = "10.0.6.0/24"

# ── Azure Firewall ────────────────────────────────────────────
firewall_name     = "fw-hub"
firewall_sku_name = "AZFW_VNet"
firewall_sku_tier = "Standard"

# ── Application Gateway ───────────────────────────────────────
appgw_name     = "agw-hub"
appgw_sku_name = "WAF_v2"
appgw_sku_tier = "WAF_v2"
appgw_capacity = 2
