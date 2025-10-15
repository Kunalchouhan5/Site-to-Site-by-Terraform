terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
    }
  }
}


provider "azurerm" {
  features {}
  subscription_id = var.subscription
  tenant_id = var.tenant_id
}