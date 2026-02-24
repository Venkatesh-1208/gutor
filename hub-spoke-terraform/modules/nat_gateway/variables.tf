##############################################################
# modules/nat_gateway/variables.tf
##############################################################
variable "nat_gateway_name"    { type = string }
variable "pip_name"            { type = string }
variable "resource_group_name" { type = string }
variable "location"            { type = string }

variable "natgw_subnet_id" {
  description = "Subnet ID to associate with the NAT Gateway"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
