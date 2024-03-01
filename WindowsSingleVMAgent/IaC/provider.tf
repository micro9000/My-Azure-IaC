terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.92.0"
    }
    azuredevops = {
      source = "microsoft/azuredevops"
      version = "0.11.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuredevops" {
}