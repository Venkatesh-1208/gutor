##############################################################
# modules/nsg/variables.tf
##############################################################
variable "resource_group_name" { type = string }
variable "location"            { type = string }

variable "nsg_management_name" {
  description = "Name for the Management subnet NSG"
  type        = string
  default     = "nsg-management"
}

variable "nsg_private_name" {
  description = "Name for the Private subnet NSG"
  type        = string
  default     = "nsg-private"
}

# Subnet IDs for association
variable "management_subnet_id" {
  description = "ID of the management subnet"
  type        = string
}

variable "private_subnet_id" {
  description = "ID of the private subnet"
  type        = string
}

# Source CIDRs used in security rules (read from subnets map)
variable "corporate_subnet_cidr" {
  description = "Corporate subnet CIDR (used as NSG source for management)"
  type        = string
}

variable "dmz_subnet_cidr" {
  description = "DMZ subnet CIDR (used as NSG source for private)"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
