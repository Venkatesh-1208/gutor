##############################################################
# modules/hub/variables.tf
# All inputs driven from root .tfvars – subnets map, boolean
# feature flags, and explicit names for every resource.
##############################################################

# ── Global ───────────────────────────────────────────────────
variable "location" {
  description = "Azure region"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# ── Resource Group ────────────────────────────────────────────
variable "resource_group_name" {
  description = "Resource group name for the Hub"
  type        = string
}

# ── Virtual Network ───────────────────────────────────────────
variable "hub_vnet_name" {
  description = "Hub VNet name"
  type        = string
}

variable "hub_vnet_address_space" {
  description = "Hub VNet address space"
  type        = list(string)
}

# ── Subnets (for_each) ────────────────────────────────────────
# Keys are logical identifiers (e.g. "dmz", "bastion").
# Special subnets must carry Azure's fixed names in .name:
#   dmz     → "AzureFirewallSubnet"
#   bastion → "AzureBastionSubnet"
variable "subnets" {
  description = "Map of subnets to create inside the Hub VNet"
  type = map(object({
    name = string
    cidr = string
  }))
}

# ── Azure Firewall ────────────────────────────────────────────
variable "deploy_firewall" {
  description = "Deploy Azure Firewall?"
  type        = bool
  default     = true
}

variable "firewall_name" {
  type    = string
  default = "fw-hub"
}

variable "firewall_pip_name" {
  type    = string
  default = "pip-fw-hub"
}

variable "firewall_policy_name" {
  type    = string
  default = "fwpol-hub"
}

variable "firewall_sku_name" {
  type    = string
  default = "AZFW_VNet"
}

variable "firewall_sku_tier" {
  type    = string
  default = "Standard"
}

# ── Application Gateway ───────────────────────────────────────
variable "deploy_appgw" {
  description = "Deploy Application Gateway?"
  type        = bool
  default     = true
}

variable "appgw_name" {
  type    = string
  default = "agw-hub"
}

variable "appgw_pip_name" {
  type    = string
  default = "pip-agw-hub"
}

variable "appgw_sku_name" {
  type    = string
  default = "WAF_v2"
}

variable "appgw_sku_tier" {
  type    = string
  default = "WAF_v2"
}

variable "appgw_capacity" {
  type    = number
  default = 2
}

# ── NAT Gateway ───────────────────────────────────────────────
variable "deploy_nat_gateway" {
  description = "Deploy NAT Gateway?"
  type        = bool
  default     = true
}

variable "nat_gateway_name" {
  type    = string
  default = "natgw-hub"
}

variable "nat_gateway_pip_name" {
  type    = string
  default = "pip-natgw-hub"
}

# ── Azure Bastion ─────────────────────────────────────────────
variable "deploy_bastion" {
  description = "Deploy Azure Bastion?"
  type        = bool
  default     = true
}

variable "bastion_name" {
  type    = string
  default = "bas-hub"
}

variable "bastion_pip_name" {
  type    = string
  default = "pip-bastion-hub"
}

# ── Internal Load Balancer ────────────────────────────────────
variable "deploy_internal_lb" {
  description = "Deploy Internal Load Balancer?"
  type        = bool
  default     = true
}

variable "internal_lb_name" {
  type    = string
  default = "lb-internal-hub"
}

# ── External Load Balancer ────────────────────────────────────
variable "deploy_external_lb" {
  description = "Deploy External Load Balancer?"
  type        = bool
  default     = true
}

variable "external_lb_name" {
  type    = string
  default = "lb-external-hub"
}

variable "external_lb_pip_name" {
  type    = string
  default = "pip-lb-external-hub"
}

# ── Route Table ───────────────────────────────────────────────
variable "route_table_name" {
  type    = string
  default = "rt-hub"
}
