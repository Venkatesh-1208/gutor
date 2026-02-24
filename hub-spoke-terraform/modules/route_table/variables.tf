##############################################################
# modules/route_table/variables.tf
##############################################################
variable "route_table_name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }

# Firewall private IP — leave empty ("") to skip the route
variable "firewall_private_ip" {
  description = "Private IP of Azure Firewall for UDR. Leave empty if Firewall not deployed."
  type        = string
  default     = ""
}

# Subnet IDs — leave empty ("") to skip that association
variable "private_subnet_id" {
  description = "ID of the private subnet. Leave empty to skip association."
  type        = string
  default     = ""
}

variable "management_subnet_id" {
  description = "ID of the management subnet. Leave empty to skip association."
  type        = string
  default     = ""
}

variable "corporate_subnet_id" {
  description = "ID of the corporate subnet. Leave empty to skip association."
  type        = string
  default     = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}
