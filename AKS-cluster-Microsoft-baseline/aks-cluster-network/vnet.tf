# This network setup is based on this baseline documentation: 
# https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks/baseline-aks?toc=%2Fazure%2Faks%2Ftoc.json&bc=%2Fazure%2Faks%2Fbreadcrumb%2Ftoc.json#network-topology

// The spoke virtual network.
// 65,536 (-reserved) IPs available to the workload, split across two subnets for AKS,
// one for App Gateway and one for Private Link endpoints.

# Virtual Network
resource "azurerm_virtual_network" "spoke_vnet" {
  name                = "cluster-vnet"
  address_space       = ["10.240.0.0/16"]
  location            = azurerm_resource_group.main_resource_group.location
  resource_group_name = azurerm_resource_group.main_resource_group.name
}
resource "azurerm_monitor_diagnostic_setting" "spoke_vnet_diagnostic_settings" {
  name                       = "cluster_vnet_diag"
  target_resource_id         = azurerm_virtual_network.spoke_vnet.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.hub_workspace.id

  metric {
    category = "AllMetrics"
  }
}


# subnet cluster nodes
resource "azurerm_subnet" "cluster_nodes_subnet" {
  name                                          = "snet-clusternodes"
  resource_group_name                           = azurerm_resource_group.main_resource_group.name
  virtual_network_name                          = azurerm_virtual_network.spoke_vnet.name
  address_prefixes                              = ["10.240.0.0/22"]
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = true
}
resource "azurerm_subnet_route_table_association" "cluster_nodes_subnet_route_table_assoc" {
  subnet_id      = azurerm_subnet.cluster_nodes_subnet.id
  route_table_id = azurerm_route_table.route_next_hop_to_firewall.id
}
resource "azurerm_subnet_network_security_group_association" "cluster_nodes_subnet_nsg_assoc" {
  subnet_id                 = azurerm_subnet.cluster_nodes_subnet.id
  network_security_group_id = azurerm_network_security_group.nodepools_nsg.id
}




# subnet for cluster ingress services
resource "azurerm_subnet" "cluster_ingress_services_subnet" {
  name                                          = "snet-clusteringressservices"
  resource_group_name                           = azurerm_resource_group.main_resource_group.name
  virtual_network_name                          = azurerm_virtual_network.spoke_vnet.name
  address_prefixes                              = ["10.240.4.0/28"]
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = false
}
resource "azurerm_subnet_route_table_association" "cluster_ingress_services_subnet_route_table_assoc" {
  subnet_id      = azurerm_subnet.cluster_ingress_services_subnet.id
  route_table_id = azurerm_route_table.route_next_hop_to_firewall.id
}
resource "azurerm_subnet_network_security_group_association" "cluster_ingress_services_subnet_nsg_assoc" {
  subnet_id                 = azurerm_subnet.cluster_ingress_services_subnet.id
  network_security_group_id = azurerm_network_security_group.internal_loadbalancer_subnet_nsg.id
}


# subnet for application gateway
resource "azurerm_subnet" "app_gateway_subnet" {
  name                                          = "snet-applicationgateway"
  resource_group_name                           = azurerm_resource_group.main_resource_group.name
  virtual_network_name                          = azurerm_virtual_network.spoke_vnet.name
  address_prefixes                              = ["10.240.5.0/24"]
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = false
}
resource "azurerm_subnet_network_security_group_association" "app_gateway_subnet_nsg_assoc" {
  subnet_id                 = azurerm_subnet.app_gateway_subnet.id
  network_security_group_id = azurerm_network_security_group.app_gateway_subnet_nsg.id
}



# subnet private endpoint
resource "azurerm_subnet" "private_endpoint_subnet" {
  name                                          = "snet-privatelinkendpoints"
  resource_group_name                           = azurerm_resource_group.main_resource_group.name
  virtual_network_name                          = azurerm_virtual_network.spoke_vnet.name
  address_prefixes                              = ["10.240.4.32/28"]
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = true
}
resource "azurerm_subnet_network_security_group_association" "private_endpoint_subnet_nsg_assoc" {
  subnet_id                 = azurerm_subnet.private_endpoint_subnet.id
  network_security_group_id = azurerm_network_security_group.private_link_endpoint_subnet_nsg.id
}



// Peer to regional hub
resource "azurerm_virtual_network_peering" "vnet_peer_spoke_to_hub" {
  name                      = substr("peer-${azurerm_virtual_network.spoke_vnet.name}-${data.azurerm_virtual_network.hub_vnet.name}", 0, 63)
  resource_group_name       = azurerm_resource_group.main_resource_group.name
  virtual_network_name      = azurerm_virtual_network.spoke_vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.hub_vnet.id
}

// Connect regional hub back to this spoke, this could also be handled via the
// hub template or via Azure Policy or Portal. How virtual networks are peered
// may vary from organization to organization. This example simply does it in
// the most direct way.
resource "azurerm_virtual_network_peering" "vnet_peer_hub_to_spoke" {
  name                = substr("peer-${data.azurerm_virtual_network.hub_vnet.name}-${azurerm_virtual_network.spoke_vnet.name}", 0, 63)
  resource_group_name = data.azurerm_resource_group.hub_resource_group.name

  depends_on                = [azurerm_virtual_network_peering.vnet-peer-spoke-to-hub]
  virtual_network_name      = data.azurerm_virtual_network.hub_vnet.id
  remote_virtual_network_id = azurerm_virtual_network.spoke_vnet.name
}


// Used as primary public entry point for cluster. Expected to be assigned to an Azure Application Gateway.
// This is a public facing IP, and would be best behind a DDoS Policy (not deployed simply for cost considerations)
resource "azurerm_public_ip" "public_ip_primary_cluster_ip" {
  name                = "public_cluster_ip_00"
  resource_group_name = azurerm_resource_group.main_resource_group.name
  location            = azurerm_resource_group.main_resource_group.location
  sku                 = "Standard"
  zones               = ["1", "2", "3"]

  allocation_method       = "Static"
  idle_timeout_in_minutes = 4
  ip_version              = "IPv4"
}
resource "azurerm_monitor_diagnostic_setting" "public_ip_primary_cluster_diagnostic_settings" {
  name                       = "public_cluster_ip_00_diag"
  target_resource_id         = azurerm_public_ip.public_ip_primary_cluster_ip.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.hub_workspace.id

  enabled_log {
    category_group = "audit"
  }

  metric {
    category = "AllMetrics"
  }
}


output "cluster_vnet_resource_id" {
  value = azurerm_virtual_network.spoke_vnet.id
}
output "cluster_nodes_subnet-id" {
  value = azurerm_subnet.cluster_nodes_subnet.id
}
output "app_gateway_public_ip_address" {
  value = azurerm_public_ip.public_ip_primary_cluster_ip.ip_address
}