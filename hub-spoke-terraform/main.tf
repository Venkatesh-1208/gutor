##############################################################
# Root main.tf – Azure Hub-Spoke Landing Zone
# Topology: Hub VNet (Firewall, AppGW, NAT-GW, LBs) +
#           N Spoke VNets peered back to the Hub
##############################################################

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }

  # Uncomment and configure for remote state
  # backend "azurerm" {
  #   resource_group_name  = "rg-tfstate"
  #   storage_account_name = "sttfstatehub"
  #   container_name       = "tfstate"
  #   key                  = "hub-spoke.terraform.tfstate"
  # }
}

##############################################################
# Provider aliases – one per subscription
##############################################################
provider "azurerm" {
  alias           = "hub"
  subscription_id = var.hub_subscription_id
  features {}
}

provider "azurerm" {
  alias           = "spoke1"
  subscription_id = var.spoke1_subscription_id
  features {}
}

provider "azurerm" {
  alias           = "spoke_n"
  subscription_id = var.spoke_n_subscription_id
  features {}
}

##############################################################
# Hub module
##############################################################
module "hub" {
  source = "./modules/hub"

  providers = {
    azurerm = azurerm.hub
  }

  location            = var.location
  resource_group_name = var.hub_resource_group_name
  hub_vnet_name       = var.hub_vnet_name
  hub_vnet_address_space = var.hub_vnet_address_space

  # Subnet CIDRs
  management_subnet_cidr    = var.management_subnet_cidr
  dmz_subnet_cidr           = var.dmz_subnet_cidr
  private_subnet_cidr       = var.private_subnet_cidr
  public_subnet_cidr        = var.public_subnet_cidr
  appgw_subnet_cidr         = var.appgw_subnet_cidr
  natgw_subnet_cidr         = var.natgw_subnet_cidr
  corporate_subnet_cidr     = var.corporate_subnet_cidr

  # Azure Firewall
  firewall_name             = var.firewall_name
  firewall_sku_name         = var.firewall_sku_name
  firewall_sku_tier         = var.firewall_sku_tier

  # Application Gateway
  appgw_name                = var.appgw_name
  appgw_sku_name            = var.appgw_sku_name
  appgw_sku_tier            = var.appgw_sku_tier
  appgw_capacity            = var.appgw_capacity

  tags = var.tags
}

##############################################################
# Spoke 1 module
##############################################################
module "spoke1" {
  source = "./modules/spoke"

  providers = {
    azurerm = azurerm.spoke1
  }

  spoke_name           = "spoke1"
  location             = var.location
  resource_group_name  = var.spoke1_resource_group_name
  vnet_name            = var.spoke1_vnet_name
  vnet_address_space   = var.spoke1_vnet_address_space
  subnet_cidr          = var.spoke1_subnet_cidr

  # VM settings
  vm_count             = var.spoke1_vm_count
  vm_size              = var.vm_size
  admin_username       = var.admin_username
  admin_password       = var.admin_password

  tags = var.tags
}

##############################################################
# Spoke N module
##############################################################
module "spoke_n" {
  source = "./modules/spoke"

  providers = {
    azurerm = azurerm.spoke_n
  }

  spoke_name           = "spoke-n"
  location             = var.location
  resource_group_name  = var.spoke_n_resource_group_name
  vnet_name            = var.spoke_n_vnet_name
  vnet_address_space   = var.spoke_n_vnet_address_space
  subnet_cidr          = var.spoke_n_subnet_cidr

  vm_count             = var.spoke_n_vm_count
  vm_size              = var.vm_size
  admin_username       = var.admin_username
  admin_password       = var.admin_password

  tags = var.tags
}

##############################################################
# VNet Peering – Hub ↔ Spoke 1
##############################################################
module "peering_hub_to_spoke1" {
  source = "./modules/peering"

  providers = {
    azurerm.local  = azurerm.hub
    azurerm.remote = azurerm.spoke1
  }

  local_vnet_name          = module.hub.vnet_name
  local_resource_group     = module.hub.resource_group_name
  local_vnet_id            = module.hub.vnet_id
  remote_vnet_name         = module.spoke1.vnet_name
  remote_resource_group    = module.spoke1.resource_group_name
  remote_vnet_id           = module.spoke1.vnet_id
  allow_gateway_transit    = true
  use_remote_gateways      = false
}

##############################################################
# VNet Peering – Hub ↔ Spoke N
##############################################################
module "peering_hub_to_spoke_n" {
  source = "./modules/peering"

  providers = {
    azurerm.local  = azurerm.hub
    azurerm.remote = azurerm.spoke_n
  }

  local_vnet_name          = module.hub.vnet_name
  local_resource_group     = module.hub.resource_group_name
  local_vnet_id            = module.hub.vnet_id
  remote_vnet_name         = module.spoke_n.vnet_name
  remote_resource_group    = module.spoke_n.resource_group_name
  remote_vnet_id           = module.spoke_n.vnet_id
  allow_gateway_transit    = true
  use_remote_gateways      = false
}
