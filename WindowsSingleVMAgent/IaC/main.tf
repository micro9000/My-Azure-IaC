resource "azurerm_resource_group" "azuredo_vm_agent" {
  name     = "AzureDO-Agent-VM-RG"
  location = "East Asia"
}

resource "random_pet" "prefix" {
  prefix = "agent"
  length = 1
}

resource "random_string" "random" {
  length  = 8
  special = false
  lower   = true
  upper   = false
  numeric = true
}