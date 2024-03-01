resource "azurerm_virtual_network" "azuredo-vm-agent" {
  name                = "agent-vm-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.azuredo-vm-agent.location
  resource_group_name = azurerm_resource_group.azuredo-vm-agent.name
}

resource "azurerm_subnet" "azuredo-vm-agent" {
  name                 = "agent-vm-subnet"
  resource_group_name  = azurerm_resource_group.azuredo-vm-agent.name
  virtual_network_name = azurerm_virtual_network.azuredo-vm-agent.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "azuredo-vm-agent" {
  name                = "agent-vm-nic"
  location            = azurerm_resource_group.azuredo-vm-agent.location
  resource_group_name = azurerm_resource_group.azuredo-vm-agent.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.azuredo-vm-agent.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "azuredo-vm-agent" {
  name                = "agent-windows-vm"
  resource_group_name = azurerm_resource_group.azuredo-vm-agent.name
  location            = azurerm_resource_group.azuredo-vm-agent.location
  size                = "Standard_F2"
  computer_name       = "windows-agent"
  admin_username      = var.vm_admin_username
  admin_password      = var.vm_admin_password
  network_interface_ids = [
    azurerm_network_interface.azuredo-vm-agent.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_id = data.azurerm_image.windows-image-2022.id
  custom_data = base64encode(data.template_file.power-shell-user-data.rendered)
}

# Data template Bash bootstrapping file
data "template_file" "power-shell-user-data" {
  template = file("AzureDOAgentSetup.ps1")
}