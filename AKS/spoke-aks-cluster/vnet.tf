# This network setup is based on this baseline documentation: 
# https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks/baseline-aks?toc=%2Fazure%2Faks%2Ftoc.json&bc=%2Fazure%2Faks%2Fbreadcrumb%2Ftoc.json#network-topology

# Virtual Network
resource "azurerm_virtual_network" "spoke_vnet" {
  name                = "${random_pet.prefix.id}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main_resource_group.location
  resource_group_name = azurerm_resource_group.main_resource_group.name
}

# subnet private endpoint
resource "azurerm_subnet" "private_endpoint_subnet" {
  name                 = "snet-privatelinkendpoints"
  resource_group_name  = azurerm_resource_group.main_resource_group.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = ["10.240.4.32/28"]
  private_link_service_network_policies_enabled = false
}

# subnet for application gateway
resource "azurerm_subnet" "app_gateway_subnet" {
  name                 = "snet-applicationgateway"
  resource_group_name  = azurerm_resource_group.main_resource_group.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = ["10.240.5.0/24"]
}

# subnet for cluster ingress services
resource "azurerm_subnet" "cluster_ingress_services_subnet" {
  name                 = "snet-clusteringressservices"
  resource_group_name  = azurerm_resource_group.main_resource_group.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = ["10.240.4.0/28"]
}


#
# Cluster node AKS subnet and NSG
#
resource "azurerm_network_security_group" "cluster_nodes_nsg" {
  name                = "acceptanceTestSecurityGroup1"
  location            = azurerm_resource_group.main_resource_group.location
  resource_group_name = azurerm_resource_group.main_resource_group.name
}
# subnet for cluster nodes
resource "azurerm_subnet" "cluster_nodes_subnet" {
  name                 = "snet-clusteringressservices"
  resource_group_name  = azurerm_resource_group.main_resource_group.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = ["10.240.0.0/22"]
}
resource "azurerm_subnet_network_security_group_association" "cluster_nodes_nsg_assoc" {
  subnet_id                 = azurerm_subnet.cluster_nodes_subnet.id
  network_security_group_id = azurerm_network_security_group.cluster_nodes_nsg.id
}