
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.92.0"
    }
  }
#   backend "azurerm" {
#     # resource_group_name  = "SharedResourcesRG"
#     # storage_account_name = "tfstatestorage02242024"
#     # container_name       = "temporary-build-agent-image-builder"
#     # key                  = "akscluster.terraform.tfstate"
#   }
}

provider "azurerm" {
  features {
  }
}