##############################################################
# modules/load_balancer/variables.tf
##############################################################
variable "resource_group_name" { type = string }
variable "location"            { type = string }

# Internal LB
variable "deploy_internal_lb" {
  description = "Deploy Internal Load Balancer?"
  type        = bool
  default     = true
}

variable "internal_lb_name" {
  type    = string
  default = "lb-internal-hub"
}

variable "private_subnet_id" {
  description = "Private subnet ID for internal LB frontend"
  type        = string
  default     = ""
}

# External LB
variable "deploy_external_lb" {
  description = "Deploy External Load Balancer?"
  type        = bool
  default     = true
}

variable "external_lb_name" {
  type    = string
  default = "lb-external-hub"
}

variable "external_lb_pip_name" {
  type    = string
  default = "pip-lb-external-hub"
}

variable "tags" {
  type    = map(string)
  default = {}
}
