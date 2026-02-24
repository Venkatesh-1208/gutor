##############################################################
# modules/vnet/variables.tf
##############################################################
variable "vnet_name" {
  description = "Virtual Network name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group to deploy the VNet into"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "address_space" {
  description = "Address space for the VNet (list of CIDRs)"
  type        = list(string)
}

# Map of subnets — each entry becomes one Azure subnet.
# Key  = logical name used to reference subnet in other modules.
# name = actual Azure subnet name (must be exact for special ones).
# cidr = address prefix.
#
# Example:
#   dmz     = { name = "AzureFirewallSubnet", cidr = "10.0.1.0/24" }
#   bastion = { name = "AzureBastionSubnet",  cidr = "10.0.7.0/26" }
variable "subnets" {
  description = "Map of subnets to create"
  type = map(object({
    name = string
    cidr = string
  }))
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
