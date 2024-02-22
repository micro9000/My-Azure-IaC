locals {
  first_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+wWK73dCr+jgQOAxNsHAnNNNMEMWOHYEccp6wJm2gotpr9katuF/ZAdou5AaW1C61slRkHRkpRRX9FA9CYBiitZgvCCz+3nWNN7l/Up54Zps/pHWGZLHNJZRYyAB6j5yVLMVHIHriY49d/GZTZVNB8GoJv9Gakwc/fuEZYYl4YDFiGMBP///TzlI4jhiJzjKnEvqPFki5p2ZRJqcbCiF4pJrxUQR/RXqVFQdbRLZgYfJ8xGB878RENq3yQ39d8dVOkq4edbkzwcUmwwwkYVPIoDGsYLaRHnG+To7FvMeyO7xDVQkMKzopTQV8AuKpyvpqu0a9pWOMaiCyDytO7GGN you@me.com"
}

resource "azurerm_resource_group" "build-agent" {
  name     = "build-agent-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "build-agent" {
  name                = "build-agent-network"
  resource_group_name = azurerm_resource_group.build-agent.name
  location            = azurerm_resource_group.build-agent.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.build-agent.name
  virtual_network_name = azurerm_virtual_network.build-agent.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_linux_virtual_machine_scale_set" "build-agent" {
  name                = "build-agent-vmss"
  resource_group_name = azurerm_resource_group.build-agent.name
  location            = azurerm_resource_group.build-agent.location
  sku                 = "Standard_F2"
  instances           = 1
  admin_username      = "adminuser"

  admin_ssh_key {
    username   = "adminuser"
    public_key = local.first_public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "build-agent"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.internal.id
    }
  }
}

resource "azurerm_virtual_machine_scale_set_extension" "build-agent" {
  name                         = "build-agent"
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.build-agent.id
  publisher                    = "Microsoft.Azure.Extensions"
  type                         = "CustomScript"
  type_handler_version         = "2.0"
  settings = jsonencode({
    "FileUris": ["https://github.com/micro9000/My-Azure-IaC/Temporary-Build-Agent/init_script.sh"],
    "commandToExecute" = "chmod +x init_script.sh && bash init_script.sh"
  })
}