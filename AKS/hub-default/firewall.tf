// Allocate three Public IP addresses to the firewall
locals {
  numFirewallIPAddressesToAssigned = 3
}
resource "azurerm_public_ip" "pub_firewall_ip_addresses" {
  count               = local.numFirewallIPAddressesToAssigned
  name                = "pub_firewall_ip_${count.index}"
  resource_group_name = azurerm_resource_group.hub_resource_group.name
  location            = azurerm_resource_group.hub_resource_group.location
  sku                 = "Standard"

  zones = ["1", "2", "3"]

  allocation_method       = "Static"
  idle_timeout_in_minutes = 4
  ip_version              = "IPv4"
}
resource "azurerm_monitor_diagnostic_setting" "pub_firewall_ip_diagnostic_settings" {
  count                      = local.numFirewallIPAddressesToAssigned
  name                       = "pub_firewall_ip_diagsettings_${count.index}"
  target_resource_id         = azurerm_public_ip.pub_firewall_ip_addresses[count.index].id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.hub_log_analytics.id

  enabled_log {
    category_group = "audit"
  }

  metric {
    category = "AllMetrics"
  }
}

# Azure Firewall start policy
resource "azurerm_firewall_policy" "firewall_policies" {
  name                     = "firewall-policies"
  resource_group_name      = azurerm_resource_group.hub_resource_group.name
  location                 = azurerm_resource_group.hub_resource_group.location
  sku                      = "Premium"
  threat_intelligence_mode = "Deny"
  insights {
    enabled                            = true
    retention_in_days                  = 30
    default_log_analytics_workspace_id = azurerm_log_analytics_workspace.hub_log_analytics.id
  }
  threat_intelligence_allowlist {
    fqdns        = []
    ip_addresses = []
  }
  intrusion_detection {
    mode = "Deny"
    # traffic_bypass
    # signature_overrides
  }
  dns {
    servers       = []
    proxy_enabled = true
  }
}

// Network hub starts out with only supporting DNS. This is only being done for
// simplicity in this deployment and is not guidance, please ensure all firewall
// rules are aligned with your security standards.
resource "azurerm_firewall_policy_rule_collection_group" "default_network_rule_collection_group" {
  name               = "default_network_rule_collection_group"
  firewall_policy_id = azurerm_firewall_policy.firewall_policies.id
  priority           = 200

  network_rule_collection {
    name     = "net_rule_org_wide_allowed"
    priority = 100
    action   = "Allow"
    rule {
      name                  = "DNS"
      description           = "Allow DNS outbound (for simplicity, adjust as needed)"
      protocols             = ["UDP"]
      source_addresses      = ["*"]
      source_ip_groups      = []
      destination_addresses = ["*"]
      destination_ip_groups = []
      destination_fqdns     = []
      destination_ports     = ["53"]
    }
  }

  // Network hub starts out with no allowances for appliction rules
}

resource "azurerm_firewall" "hub_firewall" {
  name                = "hub_firewall"
  location            = azurerm_resource_group.hub_resource_group.location
  resource_group_name = azurerm_resource_group.hub_resource_group.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Premium"
  zones               = ["1", "2", "3"]
  depends_on = [
    // This helps prevent multiple PUT updates happening to the firewall causing a CONFLICT race condition
    // Ref: https://learn.microsoft.com/azure/firewall-manager/quick-firewall-policy
    azurerm_firewall_policy_rule_collection_group.default_network_rule_collection_group
  ]
  firewall_policy_id = azurerm_firewall_policy.firewall_policies.id

  dynamic "ip_configuration" {
    for_each = range(local.numFirewallIPAddressesToAssigned)
    content {
      name                 = azurerm_public_ip.pub_firewall_ip_addresses[ip_configuration.value].name
      subnet_id            = 0 == ip_configuration.value ? azurerm_subnet.azure_firewall_subnet.id : null
      public_ip_address_id = azurerm_public_ip.pub_firewall_ip_addresses[ip_configuration.value].id
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "hub_firewall_diagnostic_settings" {
  name                       = "hub_firewall_diagsettings"
  target_resource_id         = azurerm_firewall.hub_firewall.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.hub_log_analytics.id
 
  enabled_log {
    category_group = "AllLogs"
  }

  metric {
    category = "AllMetrics"
  }
}

