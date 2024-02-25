locals {
  prefix = "temp-agent"
}

resource "azurerm_resource_group" "build-agent" {
  name     = "${local.prefix}-resources"
  location = "East Asia"
}

resource "azurerm_virtual_network" "build-agent" {
  name                = "${local.prefix}-network"
  resource_group_name = azurerm_resource_group.build-agent.name
  location            = azurerm_resource_group.build-agent.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "internal" {
  name                 = "${local.prefix}-internal"
  resource_group_name  = azurerm_resource_group.build-agent.name
  virtual_network_name = azurerm_virtual_network.build-agent.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_linux_virtual_machine_scale_set" "build-agent" {
  name                = "${local.prefix}-vmss"
  resource_group_name = azurerm_resource_group.build-agent.name
  location            = azurerm_resource_group.build-agent.location
  sku                 = "Standard_F2"
  instances           = 2
  admin_username      = "adminuser"
  admin_password      = var.vmss_admin_password
  disable_password_authentication  = false

  overprovision = false
  single_placement_group  = false

  automatic_os_upgrade_policy {
    disable_automatic_rollback  = false
    enable_automatic_os_upgrade = false
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
    name    = "${local.prefix}-interface"
    primary = true

    ip_configuration {
      name      = "${local.prefix}-internal"
      primary   = true
      subnet_id = azurerm_subnet.internal.id
    }
  }
  
  custom_data    = base64encode(data.template_file.linux-vm-cloud-init.rendered)
}


# Data template Bash bootstrapping file
data "template_file" "linux-vm-cloud-init" {
  template = file("azure-user-data.sh")
}