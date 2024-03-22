data "azurerm_resource_group" "hub_resource_group" {
  name = var.hub_resource_group_name
}

data "azurerm_virtual_network" "hub_vnet" {
  name                = var.hub_vnet_name
  resource_group_name = var.hub_resource_group_name
}

// This is the firewall that was deployed in the hub
data "azurerm_firewall" "hub_firewall" {
  name                = var.hub_firewall_name
  resource_group_name = var.hub_resource_group_name
}

// This is the networking log analytics workspace (in the hub)
data "azurerm_log_analytics_workspace" "hub_workspace" {
  name                = var.hub_workspace
  resource_group_name = var.hub_resource_group_name
}