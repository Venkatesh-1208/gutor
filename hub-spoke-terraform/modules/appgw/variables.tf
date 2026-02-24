##############################################################
# modules/appgw/variables.tf
##############################################################
variable "appgw_name"           { type = string }
variable "pip_name"             { type = string }
variable "resource_group_name"  { type = string }
variable "location"             { type = string }

variable "sku_name" {
  description = "AppGW SKU name (WAF_v2)"
  type        = string
  default     = "WAF_v2"
}

variable "sku_tier" {
  description = "AppGW SKU tier (WAF_v2)"
  type        = string
  default     = "WAF_v2"
}

variable "capacity" {
  description = "Instance count (1 = Test, 2 = Prod)"
  type        = number
  default     = 2
}

variable "appgw_subnet_id" {
  description = "ID of the Application Gateway subnet"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
