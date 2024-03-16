terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.92.0"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "0.11.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }
  backend "azurerm" {
    # resource_group_name  = "SharedResourcesRG"
    # storage_account_name = "tfstatestorage02242024"
    # container_name       = "temporary-build-agent-image-builder"
    # key                  = "akscluster.terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

provider "azuredevops" {
}

provider "random" {
  # Configuration options
}