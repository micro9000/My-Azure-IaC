# The regional hub network
resource "azurerm_virtual_network" "hub_vnet" {
  name                = "${random_pet.prefix.id}-hubvnet"
  address_space       = [var.hubVirtualNetworkAddressSpace]
  location            = azurerm_resource_group.hub_resource_group.location
  resource_group_name = azurerm_resource_group.hub_resource_group.name
}

resource "azurerm_monitor_diagnostic_setting" "hub_vnet_diagnostic_settings" {
  name                       = "hub_vnet_diagsettings"
  target_resource_id         = azurerm_virtual_network.hub_vnet.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.hub_log_analytics.id

  metric {
    category = "AllMetrics"
  }
}

# Subnets
resource "azurerm_subnet" "azure_firewall_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.hub_resource_group.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = [var.hubVirtualNetworkAzureFirewallSubnetAddressSpace]
}

resource "azurerm_subnet" "gateway_subnet" {
  name                 = "gateway-subnet"
  resource_group_name  = azurerm_resource_group.hub_resource_group.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = [var.hubVirtualNetworkGatewaySubnetAddressSpace]
}

resource "azurerm_subnet" "azure_bastion_subnet" {
  name                 = "azure-bastion-subnet"
  resource_group_name  = azurerm_resource_group.hub_resource_group.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = [var.hubVirtualNetworkBastionSubnetAddressSpace]
}
resource "azurerm_subnet_network_security_group_association" "azure_bastion_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.azure_bastion_subnet.id
  network_security_group_id = azurerm_network_security_group.bastion_nsg.id
}

output "hub_vnet_id" {
  value = azurerm_virtual_network.hub_vnet.id
}

