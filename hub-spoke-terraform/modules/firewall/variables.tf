##############################################################
# modules/firewall/variables.tf
##############################################################
variable "firewall_name"      { type = string }
variable "pip_name"           { type = string }
variable "policy_name"        { type = string }
variable "resource_group_name" { type = string }
variable "location"           { type = string }

variable "sku_name" {
  description = "Firewall SKU name (AZFW_VNet)"
  type        = string
  default     = "AZFW_VNet"
}

variable "sku_tier" {
  description = "Firewall SKU tier: Standard or Premium"
  type        = string
  default     = "Standard"
}

# The DMZ subnet ID — must be the AzureFirewallSubnet
variable "dmz_subnet_id" {
  description = "ID of the AzureFirewallSubnet"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
