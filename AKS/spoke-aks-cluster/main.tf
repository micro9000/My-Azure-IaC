

resource "random_pet" "prefix" {
  prefix = var.resource_group_name_prefix
  length = 1
}

resource "azurerm_resource_group" "main_resource_group" {
  name     = "${upper(random_pet.prefix.id)}-RG"
  location = "East Asia"
}


resource "random_string" "random" {
  length  = 8
  special = false
  lower   = true
  upper   = false
  numeric = true
}


data "azurerm_client_config" "current" {}
