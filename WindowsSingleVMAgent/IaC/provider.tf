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
  backend "azurerm" {
    # resource_group_name  = "SharedResourcesRG"
    # storage_account_name = "tfstatestorage02242024"
    # container_name       = "temporary-build-agent-image-builder"
    # key                  = "prod.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

provider "azuredevops" {
}