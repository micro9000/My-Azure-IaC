data "azurerm_image" "windows-image-2022" {
  name                = "Runner-Image-Windows2022"
  resource_group_name = "AzDOAgentImagesRG"
}