variable "spoke_name" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "vnet_name" { type = string }
variable "vnet_address_space" { type = list(string) }
variable "subnet_cidr" { type = string }

variable "vm_count" {
  type    = number
  default = 2
}
variable "vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}
variable "admin_username" { type = string }
variable "admin_password" {
  type      = string
  sensitive = true
}

# Hub Firewall private IP for routing
variable "hub_firewall_private_ip" {
  type    = string
  default = ""
  description = "Hub Azure Firewall private IP. Leave empty to skip UDR creation."
}

variable "tags" {
  type    = map(string)
  default = {}
}
