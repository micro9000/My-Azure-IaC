resource "azurerm_resource_group" "hub_resource_group" {
  name     = var.resource_group_name
  location = var.location
}


resource "random_pet" "prefix" {
  prefix = "hubnetwork"
  length = 1
}

resource "random_string" "random" {
  length  = 8
  special = false
  lower   = true
  upper   = false
  numeric = true
}


data "azurerm_client_config" "current" {}


# These TF configs are based on this: https://github.com/Raniel-Dev-Foundation/aks-baseline-03222024/blob/main/networking/hub-default.bicep