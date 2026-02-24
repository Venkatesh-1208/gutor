##############################################################
# modules/bastion/variables.tf
##############################################################
variable "bastion_name"        { type = string }
variable "pip_name"            { type = string }
variable "resource_group_name" { type = string }
variable "location"            { type = string }

variable "bastion_subnet_id" {
  description = "ID of AzureBastionSubnet (exact name required by Azure)"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
