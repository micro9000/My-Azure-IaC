resource "azurerm_log_analytics_workspace" "main_log_analytics" {
  name                = "acctest-01"
  location            = azurerm_resource_group.main_resource_group.location
  resource_group_name = azurerm_resource_group.main_resource_group.name
  sku                 = "Free" #"PerGB2018"
  retention_in_days   = 30
}