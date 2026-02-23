##############################################################
# Root main.tf – Azure Hub Subscription Deployment
# Topology: Hub VNet (Firewall, AppGW, NAT-GW, LBs)
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
  #   key                  = "hub.terraform.tfstate"
  # }
}

##############################################################
# Provider – Hub subscription only
##############################################################
provider "azurerm" {
  alias           = "hub"
  subscription_id = var.hub_subscription_id
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
