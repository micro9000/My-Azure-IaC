resource "azurerm_virtual_network" "azuredo_vm_agent" {
  name                = "agent-vm-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.azuredo_vm_agent.location
  resource_group_name = azurerm_resource_group.azuredo_vm_agent.name
}

resource "azurerm_subnet" "azuredo_vm_agent" {
  name                 = "agent-vm-subnet"
  resource_group_name  = azurerm_resource_group.azuredo_vm_agent.name
  virtual_network_name = azurerm_virtual_network.azuredo_vm_agent.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "azuredo_vm_agent" {
  name                = "${random_pet.prefix.id}-public-ip"
  location            = azurerm_resource_group.azuredo_vm_agent.location
  resource_group_name = azurerm_resource_group.azuredo_vm_agent.name
  allocation_method   = "Dynamic"
}


resource "azurerm_network_security_group" "azuredo_vm_agent" {
  name                = "${random_pet.prefix.id}-nsg"
  location            = azurerm_resource_group.azuredo_vm_agent.location
  resource_group_name = azurerm_resource_group.azuredo_vm_agent.name

  security_rule {
    name                       = "RDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


resource "azurerm_network_interface" "azuredo_vm_agent" {
  name                = "agent-vm-nic"
  location            = azurerm_resource_group.azuredo_vm_agent.location
  resource_group_name = azurerm_resource_group.azuredo_vm_agent.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.azuredo_vm_agent.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.azuredo_vm_agent.id
  }
}

resource "azurerm_network_interface_security_group_association" "azuredo_vm_agent" {
  network_interface_id      = azurerm_network_interface.azuredo_vm_agent.id
  network_security_group_id = azurerm_network_security_group.azuredo_vm_agent.id
}


# Create storage account for boot diagnostics
resource "azurerm_storage_account" "azuredo_vm_agent" {
  name                     = "diag${random_string.random.id}"
  location                 = azurerm_resource_group.azuredo_vm_agent.location
  resource_group_name      = azurerm_resource_group.azuredo_vm_agent.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_windows_virtual_machine" "azuredo_vm_agent" {
  name                = "agent-windows-vm"
  resource_group_name = azurerm_resource_group.azuredo_vm_agent.name
  location            = azurerm_resource_group.azuredo_vm_agent.location
  size                = "Standard_F2"
  computer_name       = var.vm_computer_name
  admin_username      = var.vm_admin_username
  admin_password      = var.vm_admin_password
  network_interface_ids = [
    azurerm_network_interface.azuredo_vm_agent.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_id = data.azurerm_image.windows-image-2022.id

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.azuredo_vm_agent.primary_blob_endpoint
  }
}

resource "azurerm_virtual_machine_extension" "test_ps_script" {
  name                 = "${random_pet.prefix.id}-wsi"
  virtual_machine_id   = azurerm_windows_virtual_machine.azuredo_vm_agent.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  protected_settings = <<SETTINGS
    {
      "commandToExecute": "powershell -encodedCommand ${textencodebase64(file("${path.module}/scripts/AzureDOAgentSetup.ps1"), "UTF-16LE")}"
    }
  SETTINGS
}
