// This Log Analytics workspace stores logs from the regional hub network, its spokes, and bastion.
// Log analytics is a regional resource, as such there will be one workspace per hub (region)
resource "azurerm_log_analytics_workspace" "hub_log_analytics" {
  name                = "${var.prefix}-la"
  location            = azurerm_resource_group.hub_resource_group.location
  resource_group_name = azurerm_resource_group.hub_resource_group.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  internet_ingestion_enabled = true
  internet_query_enabled = true
  cmk_for_query_forced = false
  local_authentication_disabled = true
  allow_resource_only_permissions = true
  daily_quota_gb = -1
}


resource "azurerm_monitor_diagnostic_setting" "lahub_diagnostic_settings" {
  name               = "la_diagsettings"
  target_resource_id = azurerm_log_analytics_workspace.hub_log_analytics.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.hub_log_analytics.id

  enabled_log {
    category_group = "audit"
  }

  metric {
    category = "AllMetrics"
  }
}