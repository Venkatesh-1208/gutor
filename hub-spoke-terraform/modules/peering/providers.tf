##############################################################
# modules/peering/providers.tf
# Declares the two provider aliases needed for cross-sub peering
##############################################################
terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = "~> 3.90"
      configuration_aliases = [azurerm.local, azurerm.remote]
    }
  }
}
