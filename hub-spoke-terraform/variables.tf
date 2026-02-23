##############################################################
# variables.tf – All input variables for the Hub-Spoke topology
##############################################################

# ── Subscriptions ────────────────────────────────────────────
variable "hub_subscription_id" {
  description = "Azure Subscription ID for the Hub"
  type        = string
}

variable "spoke1_subscription_id" {
  description = "Azure Subscription ID for Spoke 1"
  type        = string
}

variable "spoke_n_subscription_id" {
  description = "Azure Subscription ID for Spoke N"
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
    Environment = "Production"
    ManagedBy   = "Terraform"
    Architecture = "HubSpoke"
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

# ── Spoke 1 ──────────────────────────────────────────────────
variable "spoke1_resource_group_name" {
  description = "Resource group name for Spoke 1"
  type        = string
  default     = "rg-spoke1"
}

variable "spoke1_vnet_name" {
  description = "Spoke 1 VNet name"
  type        = string
  default     = "vnet-spoke1"
}

variable "spoke1_vnet_address_space" {
  description = "Spoke 1 VNet address space"
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "spoke1_subnet_cidr" {
  description = "Spoke 1 workload subnet CIDR"
  type        = string
  default     = "10.1.0.0/24"
}

variable "spoke1_vm_count" {
  description = "Number of VMs to deploy in Spoke 1"
  type        = number
  default     = 2
}

# ── Spoke N ──────────────────────────────────────────────────
variable "spoke_n_resource_group_name" {
  description = "Resource group name for Spoke N"
  type        = string
  default     = "rg-spoke-n"
}

variable "spoke_n_vnet_name" {
  description = "Spoke N VNet name"
  type        = string
  default     = "vnet-spoke-n"
}

variable "spoke_n_vnet_address_space" {
  description = "Spoke N VNet address space"
  type        = list(string)
  default     = ["10.2.0.0/16"]
}

variable "spoke_n_subnet_cidr" {
  description = "Spoke N workload subnet CIDR"
  type        = string
  default     = "10.2.0.0/24"
}

variable "spoke_n_vm_count" {
  description = "Number of VMs to deploy in Spoke N"
  type        = number
  default     = 2
}

# ── VM shared config ─────────────────────────────────────────
variable "vm_size" {
  description = "Size of the Virtual Machines in spokes"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "admin_username" {
  description = "Administrator username for VMs"
  type        = string
  default     = "azureadmin"
}

variable "admin_password" {
  description = "Administrator password for VMs (use Key Vault in production)"
  type        = string
  sensitive   = true
}
