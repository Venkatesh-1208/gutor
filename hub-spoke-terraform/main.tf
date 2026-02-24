##############################################################
# main.tf – Hub Subscription Deployment
#
# Each module is independently toggleable via deploy_* flags.
# Locals resolve the correct ID/name whether a resource was
# just created by Terraform or already exists in Azure.
#
# Usage:
#   terraform plan  -var-file="environments/test/test.tfvars"
#   terraform apply -var-file="environments/prod/prod.tfvars"
##############################################################

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
  # backend "azurerm" { ... }
}

provider "azurerm" {
  alias           = "hub"
  subscription_id = var.hub_subscription_id
  features {}
}

##############################################################
# LOCALS – Resolve outputs from modules OR fall back to
#          static variables when a resource is pre-existing.
##############################################################
locals {
  # Resource Group name
  rg_name = var.deploy_resource_group ? module.resource_group[0].name : var.resource_group_name

  # Subnet IDs — from new VNet or from existing_subnet_ids variable
  subnet_ids = var.deploy_vnet ? module.vnet[0].subnet_ids : var.existing_subnet_ids

  # Subnet CIDRs (used by NSG rules)
  subnet_cidrs = var.deploy_vnet ? module.vnet[0].subnet_cidrs : {
    corporate = ""
    dmz       = ""
  }

  # Firewall private IP (used by Route Table UDR)
  firewall_private_ip = var.deploy_firewall ? try(module.firewall[0].private_ip, "") : var.existing_firewall_private_ip
}

##############################################################
# 1. RESOURCE GROUP
##############################################################
module "resource_group" {
  count    = var.deploy_resource_group ? 1 : 0
  source   = "./modules/resource_group"

  providers = { azurerm = azurerm.hub }

  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

##############################################################
# 2. VIRTUAL NETWORK + SUBNETS (for_each inside module)
##############################################################
module "vnet" {
  count    = var.deploy_vnet ? 1 : 0
  source   = "./modules/vnet"

  providers = { azurerm = azurerm.hub }

  vnet_name           = var.hub_vnet_name
  resource_group_name = local.rg_name
  location            = var.location
  address_space       = var.hub_vnet_address_space
  subnets             = var.subnets
  tags                = var.tags

  depends_on = [module.resource_group]
}

##############################################################
# 3. NSG
##############################################################
module "nsg" {
  count    = var.deploy_nsg ? 1 : 0
  source   = "./modules/nsg"

  providers = { azurerm = azurerm.hub }

  resource_group_name  = local.rg_name
  location             = var.location
  nsg_management_name  = var.nsg_management_name
  nsg_private_name     = var.nsg_private_name
  management_subnet_id = local.subnet_ids["management"]
  private_subnet_id    = local.subnet_ids["private"]
  corporate_subnet_cidr = local.subnet_cidrs["corporate"]
  dmz_subnet_cidr       = local.subnet_cidrs["dmz"]
  tags                 = var.tags

  depends_on = [module.vnet]
}

##############################################################
# 4. AZURE FIREWALL
##############################################################
module "firewall" {
  count    = var.deploy_firewall ? 1 : 0
  source   = "./modules/firewall"

  providers = { azurerm = azurerm.hub }

  firewall_name       = var.firewall_name
  pip_name            = var.firewall_pip_name
  policy_name         = var.firewall_policy_name
  resource_group_name = local.rg_name
  location            = var.location
  sku_name            = var.firewall_sku_name
  sku_tier            = var.firewall_sku_tier
  dmz_subnet_id       = local.subnet_ids["dmz"]
  tags                = var.tags

  depends_on = [module.vnet]
}

##############################################################
# 5. ROUTE TABLE
##############################################################
module "route_table" {
  count    = var.deploy_route_table ? 1 : 0
  source   = "./modules/route_table"

  providers = { azurerm = azurerm.hub }

  route_table_name     = var.route_table_name
  resource_group_name  = local.rg_name
  location             = var.location
  firewall_private_ip  = local.firewall_private_ip
  private_subnet_id    = try(local.subnet_ids["private"], "")
  management_subnet_id = try(local.subnet_ids["management"], "")
  corporate_subnet_id  = try(local.subnet_ids["corporate"], "")
  tags                 = var.tags

  depends_on = [module.firewall, module.vnet]
}

##############################################################
# 6. NAT GATEWAY
##############################################################
module "nat_gateway" {
  count    = var.deploy_nat_gateway ? 1 : 0
  source   = "./modules/nat_gateway"

  providers = { azurerm = azurerm.hub }

  nat_gateway_name    = var.nat_gateway_name
  pip_name            = var.nat_gateway_pip_name
  resource_group_name = local.rg_name
  location            = var.location
  natgw_subnet_id     = local.subnet_ids["natgw"]
  tags                = var.tags

  depends_on = [module.vnet]
}

##############################################################
# 7. APPLICATION GATEWAY
##############################################################
module "appgw" {
  count    = var.deploy_appgw ? 1 : 0
  source   = "./modules/appgw"

  providers = { azurerm = azurerm.hub }

  appgw_name          = var.appgw_name
  pip_name            = var.appgw_pip_name
  resource_group_name = local.rg_name
  location            = var.location
  sku_name            = var.appgw_sku_name
  sku_tier            = var.appgw_sku_tier
  capacity            = var.appgw_capacity
  appgw_subnet_id     = local.subnet_ids["appgw"]
  tags                = var.tags

  depends_on = [module.vnet]
}

##############################################################
# 8. LOAD BALANCERS (Internal + External)
##############################################################
module "load_balancer" {
  count    = (var.deploy_internal_lb || var.deploy_external_lb) ? 1 : 0
  source   = "./modules/load_balancer"

  providers = { azurerm = azurerm.hub }

  resource_group_name  = local.rg_name
  location             = var.location
  deploy_internal_lb   = var.deploy_internal_lb
  internal_lb_name     = var.internal_lb_name
  private_subnet_id    = try(local.subnet_ids["private"], "")
  deploy_external_lb   = var.deploy_external_lb
  external_lb_name     = var.external_lb_name
  external_lb_pip_name = var.external_lb_pip_name
  tags                 = var.tags

  depends_on = [module.vnet]
}

##############################################################
# 9. AZURE BASTION
##############################################################
module "bastion" {
  count    = var.deploy_bastion ? 1 : 0
  source   = "./modules/bastion"

  providers = { azurerm = azurerm.hub }

  bastion_name        = var.bastion_name
  pip_name            = var.bastion_pip_name
  resource_group_name = local.rg_name
  location            = var.location
  bastion_subnet_id   = local.subnet_ids["bastion"]
  tags                = var.tags

  depends_on = [module.vnet]
}
