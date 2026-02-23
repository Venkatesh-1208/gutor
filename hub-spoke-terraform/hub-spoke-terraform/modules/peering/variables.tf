variable "local_vnet_name" { type = string }
variable "local_resource_group" { type = string }
variable "local_vnet_id" { type = string }

variable "remote_vnet_name" { type = string }
variable "remote_resource_group" { type = string }
variable "remote_vnet_id" { type = string }

variable "allow_gateway_transit" {
  type    = bool
  default = false
}

variable "use_remote_gateways" {
  type    = bool
  default = false
}
