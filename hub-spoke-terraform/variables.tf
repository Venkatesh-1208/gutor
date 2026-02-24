##############################################################
# variables.tf – All inputs for the Hub deployment
# Every resource name, flag, and network setting is set here
# and overridden per-environment via .tfvars files.
##############################################################

# ─────────────────────────────────────────────────────────────
# SUBSCRIPTION & LOCATION
# ─────────────────────────────────────────────────────────────
variable "hub_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region (e.g. eastus)"
  type        = string
}

variable "tags" {
  description = "Tags applied to every resource"
  type        = map(string)
  default     = {}
}

# ─────────────────────────────────────────────────────────────
# RESOURCE GROUP
# ─────────────────────────────────────────────────────────────
variable "deploy_resource_group" {
  description = "true = create RG | false = use existing RG (set resource_group_name)"
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "Resource Group name (created or referenced)"
  type        = string
}

# ─────────────────────────────────────────────────────────────
# VIRTUAL NETWORK & SUBNETS
# ─────────────────────────────────────────────────────────────
variable "deploy_vnet" {
  description = "true = create VNet + Subnets | false = use existing (set existing_subnet_ids)"
  type        = bool
  default     = true
}

variable "hub_vnet_name" {
  description = "Hub VNet name"
  type        = string
}

variable "hub_vnet_address_space" {
  description = "Hub VNet address space"
  type        = list(string)
}

# One entry per subnet. Add/remove subnets here — no module changes needed.
# Special names: dmz key → "AzureFirewallSubnet", bastion key → "AzureBastionSubnet"
variable "subnets" {
  description = "Map of subnets (for_each in vnet module)"
  type = map(object({
    name = string
    cidr = string
  }))
}

# Fallback IDs — only needed when deploy_vnet = false (pre-existing VNet)
variable "existing_subnet_ids" {
  description = "Map of subnet IDs when reusing an existing VNet (deploy_vnet = false)"
  type        = map(string)
  default     = {}
}

# ─────────────────────────────────────────────────────────────
# NSG
# ─────────────────────────────────────────────────────────────
variable "deploy_nsg" {
  description = "true = create NSGs | false = skip"
  type        = bool
  default     = true
}

variable "nsg_management_name" { type = string; default = "nsg-management" }
variable "nsg_private_name"    { type = string; default = "nsg-private" }

# ─────────────────────────────────────────────────────────────
# ROUTE TABLE
# ─────────────────────────────────────────────────────────────
variable "deploy_route_table" {
  description = "true = create Route Table | false = skip"
  type        = bool
  default     = true
}

variable "route_table_name" { type = string; default = "rt-hub" }

# ─────────────────────────────────────────────────────────────
# AZURE FIREWALL
# ─────────────────────────────────────────────────────────────
variable "deploy_firewall" {
  description = "true = deploy Azure Firewall | false = skip"
  type        = bool
  default     = true
}

variable "firewall_name"        { type = string; default = "fw-hub" }
variable "firewall_pip_name"    { type = string; default = "pip-fw-hub" }
variable "firewall_policy_name" { type = string; default = "fwpol-hub" }
variable "firewall_sku_name"    { type = string; default = "AZFW_VNet" }
variable "firewall_sku_tier"    { type = string; default = "Standard" }

# Fallback — only used when deploy_firewall = false
variable "existing_firewall_private_ip" {
  description = "Private IP of pre-existing Firewall (deploy_firewall = false)"
  type        = string
  default     = ""
}

# ─────────────────────────────────────────────────────────────
# NAT GATEWAY
# ─────────────────────────────────────────────────────────────
variable "deploy_nat_gateway" {
  description = "true = deploy NAT Gateway | false = skip"
  type        = bool
  default     = true
}

variable "nat_gateway_name"     { type = string; default = "natgw-hub" }
variable "nat_gateway_pip_name" { type = string; default = "pip-natgw-hub" }

# ─────────────────────────────────────────────────────────────
# APPLICATION GATEWAY
# ─────────────────────────────────────────────────────────────
variable "deploy_appgw" {
  description = "true = deploy Application Gateway | false = skip"
  type        = bool
  default     = true
}

variable "appgw_name"     { type = string; default = "agw-hub" }
variable "appgw_pip_name" { type = string; default = "pip-agw-hub" }
variable "appgw_sku_name" { type = string; default = "WAF_v2" }
variable "appgw_sku_tier" { type = string; default = "WAF_v2" }
variable "appgw_capacity" { type = number; default = 2 }

# ─────────────────────────────────────────────────────────────
# LOAD BALANCERS
# ─────────────────────────────────────────────────────────────
variable "deploy_internal_lb" {
  description = "true = deploy Internal LB | false = skip"
  type        = bool
  default     = true
}

variable "internal_lb_name" { type = string; default = "lb-internal-hub" }

variable "deploy_external_lb" {
  description = "true = deploy External LB | false = skip"
  type        = bool
  default     = true
}

variable "external_lb_name"     { type = string; default = "lb-external-hub" }
variable "external_lb_pip_name" { type = string; default = "pip-lb-external-hub" }

# ─────────────────────────────────────────────────────────────
# AZURE BASTION
# ─────────────────────────────────────────────────────────────
variable "deploy_bastion" {
  description = "true = deploy Azure Bastion | false = skip"
  type        = bool
  default     = true
}

variable "bastion_name"     { type = string; default = "bas-hub" }
variable "bastion_pip_name" { type = string; default = "pip-bastion-hub" }
