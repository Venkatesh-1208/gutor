##############################################################
# variables.tf – Input variables for Hub subscription deployment
##############################################################

# ── Subscriptions ────────────────────────────────────────────
variable "hub_subscription_id" {
  description = "Azure Subscription ID for the Hub"
  type        = string
}

# ── Global ───────────────────────────────────────────────────
variable "location" {
  description = "Azure region to deploy resources"
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment  = "Production"
    ManagedBy    = "Terraform"
    Architecture = "Hub"
  }
}

# ── Hub VNet ─────────────────────────────────────────────────
variable "hub_resource_group_name" {
  description = "Resource group name for the Hub"
  type        = string
  default     = "rg-hub-network"
}

variable "hub_vnet_name" {
  description = "Hub Virtual Network name"
  type        = string
  default     = "vnet-hub"
}

variable "hub_vnet_address_space" {
  description = "Hub VNet address space"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

# ── Hub Subnet CIDRs ─────────────────────────────────────────
variable "management_subnet_cidr" {
  description = "CIDR for the Management subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "dmz_subnet_cidr" {
  description = "CIDR for the DMZ subnet (Azure Firewall lives here)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR for the Private subnet (Internal Load Balancer)"
  type        = string
  default     = "10.0.2.0/24"
}

variable "public_subnet_cidr" {
  description = "CIDR for the Public subnet (External Load Balancer)"
  type        = string
  default     = "10.0.3.0/24"
}

variable "appgw_subnet_cidr" {
  description = "CIDR for the Application Gateway subnet"
  type        = string
  default     = "10.0.4.0/24"
}

variable "natgw_subnet_cidr" {
  description = "CIDR for the NAT Gateway subnet"
  type        = string
  default     = "10.0.5.0/24"
}

variable "corporate_subnet_cidr" {
  description = "CIDR for the Corporate subnet"
  type        = string
  default     = "10.0.6.0/24"
}

# ── Azure Firewall ───────────────────────────────────────────
variable "firewall_name" {
  description = "Name of the Azure Firewall"
  type        = string
  default     = "fw-hub"
}

variable "firewall_sku_name" {
  description = "Azure Firewall SKU name"
  type        = string
  default     = "AZFW_VNet"
}

variable "firewall_sku_tier" {
  description = "Azure Firewall SKU tier (Standard or Premium)"
  type        = string
  default     = "Standard"
}

# ── Application Gateway ──────────────────────────────────────
variable "appgw_name" {
  description = "Name of the Application Gateway"
  type        = string
  default     = "agw-hub"
}

variable "appgw_sku_name" {
  description = "Application Gateway SKU name"
  type        = string
  default     = "WAF_v2"
}

variable "appgw_sku_tier" {
  description = "Application Gateway SKU tier"
  type        = string
  default     = "WAF_v2"
}

variable "appgw_capacity" {
  description = "Application Gateway capacity (instance count)"
  type        = number
  default     = 2
}
