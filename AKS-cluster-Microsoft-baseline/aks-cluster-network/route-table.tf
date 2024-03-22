
// Next hop to the regional hub's Azure Firewall
resource "azurerm_route_table" "route_next_hop_to_firewall" {
  name                          = "route-to-${var.location}-hub-fw"
  location                      = azurerm_resource_group.main_resource_group.location
  resource_group_name           = azurerm_resource_group.main_resource_group.name

  route {
    name           = "r-nexthop-to-fw"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = data.azurerm_firewall.hub_firewall.ip_configuration[0].private_ip_address
  }
}