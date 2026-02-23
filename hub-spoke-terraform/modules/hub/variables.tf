variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "hub_vnet_name" { type = string }
variable "hub_vnet_address_space" { type = list(string) }

variable "management_subnet_cidr" { type = string }
variable "dmz_subnet_cidr" { type = string }
variable "private_subnet_cidr" { type = string }
variable "public_subnet_cidr" { type = string }
variable "appgw_subnet_cidr" { type = string }
variable "natgw_subnet_cidr" { type = string }
variable "corporate_subnet_cidr" { type = string }
variable "bastion_subnet_cidr" {
  type    = string
  default = "10.0.7.0/26"
}

variable "firewall_name" { type = string }
variable "firewall_sku_name" { type = string }
variable "firewall_sku_tier" { type = string }

variable "appgw_name" { type = string }
variable "appgw_sku_name" { type = string }
variable "appgw_sku_tier" { type = string }
variable "appgw_capacity" { type = number }

variable "tags" {
  type    = map(string)
  default = {}
}
