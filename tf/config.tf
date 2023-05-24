terraform {
  required_providers {
    azurerm    = {
      source   = "hashicorp/azurerm"
    }
  }
  # backend "azurerm" {}
}
provider "azurerm" {
  features {}
}