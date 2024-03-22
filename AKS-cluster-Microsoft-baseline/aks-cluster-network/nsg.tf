
// Default NSG on the AKS nodepools. Feel free to constrict further.
resource "azurerm_network_security_group" "nodepools_nsg" {
  name                = "nsg_cluster_nodepools"
  location            = azurerm_resource_group.main_resource_group.location
  resource_group_name = azurerm_resource_group.main_resource_group.name
}
resource "azurerm_monitor_diagnostic_setting" "nodepools_nsg_diagnostic_settings" {
  name                       = "nodepools_nsg_diag"
  target_resource_id         = azurerm_network_security_group.nodepools_nsg.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.hub_workspace.id

  metric {
    category = "AllLogs"
  }
}


// Default NSG on the AKS internal load balancer subnet. Feel free to constrict further.
resource "azurerm_network_security_group" "internal_loadbalancer_subnet_nsg" {
  name                = "nsg_internal_loadbalancer_subnet"
  location            = azurerm_resource_group.main_resource_group.location
  resource_group_name = azurerm_resource_group.main_resource_group.name
}
resource "azurerm_monitor_diagnostic_setting" "nodepools_nsg_diagnostic_settings" {
  name                       = "internal_loadbalancer_subnet_nsg_diag"
  target_resource_id         = azurerm_network_security_group.internal_loadbalancer_subnet_nsg.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.hub_workspace.id

  metric {
    category = "AllLogs"
  }
}


// NSG on the Application Gateway subnet.
resource "azurerm_network_security_group" "app_gateway_subnet_nsg" {
  name                = "nsg_app_gateway_subnet"
  location            = azurerm_resource_group.main_resource_group.location
  resource_group_name = azurerm_resource_group.main_resource_group.name

  security_rule {
    name                       = "Allow443Inbound"
    description                = "Allow ALL web traffic into 443. (If you wanted to allow-list specific IPs, this is where you'd list them.)"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "Internet"
    destination_port_range     = "443"
    destination_address_prefix = "VirtualNetwork"
    direction                  = "Inbound"
    access                     = "Allow"
    priority                   = 100
  }

  security_rule {
    name                       = "AllowControlPlaneInbound"
    description                = "Allow Azure Control Plane in. (https://learn.microsoft.com/azure/application-gateway/configuration-infrastructure#network-security-groups)"
    protocol                   = "*"
    source_port_range          = "*"
    source_address_prefix      = "GatewayManager"
    destination_port_range     = "65200-65535"
    destination_address_prefix = "*"
    direction                  = "Inbound"
    access                     = "Allow"
    priority                   = 110
  }

  security_rule {
    name                       = "AllowHealthProbesInbound"
    description                = "Allow Azure Health Probes in. (https://learn.microsoft.com/azure/application-gateway/configuration-infrastructure#network-security-groups)"
    protocol                   = "*"
    source_port_range          = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_port_range     = "*"
    destination_address_prefix = "*"
    direction                  = "Inbound"
    access                     = "Allow"
    priority                   = 120
  }

  security_rule {
    name                       = "DenyAllInbound"
    description                = "No further inbound traffic allowed."
    protocol                   = "*"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "*"
    destination_address_prefix = "*"
    direction                  = "Inbound"
    access                     = "Deny"
    priority                   = 1000
  }

  security_rule {
    name                       = "AllowAllOutbound"
    description                = "App Gateway v2 requires full outbound access."
    protocol                   = "*"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "*"
    destination_address_prefix = "*"
    direction                  = "Outboud"
    access                     = "Allow"
    priority                   = 1000
  }
}
resource "azurerm_monitor_diagnostic_setting" "app_gateway_subnet_nsg_diagnostic_settings" {
  name                       = "app_gateway_subnet_nsg_diag"
  target_resource_id         = azurerm_network_security_group.app_gateway_subnet_nsg.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.hub_workspace.id

  metric {
    category = "AllLogs"
  }
}

// NSG on the Private Link subnet.
resource "azurerm_network_security_group" "private_link_endpoint_subnet_nsg" {
  name                = "nsg_cluster_vnet_private_link_endpoints"
  location            = azurerm_resource_group.main_resource_group.location
  resource_group_name = azurerm_resource_group.main_resource_group.name

  security_rule {
    name                       = "AllowAll443InFromVnet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  security_rule {
    name                       = "DenyAllOutbound"
    priority                   = 1000
    direction                  = "Outboud"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_monitor_diagnostic_setting" "private_link_endpoint_subnet_nsg_diagnostic_settings" {
  name                       = "cluster_vnet_private_link_endpoints_nsg_diag"
  target_resource_id         = azurerm_network_security_group.private_link_endpoint_subnet_nsg.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.hub_workspace.id

  metric {
    category = "AllLogs"
  }
}