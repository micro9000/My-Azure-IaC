locals {
  first_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDNswICCIklyE4C5Q8rNMCYgQ3oHBOkD2SZUIzTlT0OfIJ8bPf35EW4OzMEsq7ZFlx8YHs8RHbcut+5jC8hDFubYX2QnVpTYNVIHBhUkItUtdZX87vMy9oSocssCF/xr4w9lOQgLtbKWG2IjRWL3Vy711jsFaGD+WDDf7K5D48nDoR+AI/cLyJLyFRe0XXvTuz/57ZEw9XCYASKUUdJ6tXpszexQzYuDOjrLw7yzT2+phnS1oOYjU9k/nvdxQXmaok8NMXHpFrIwl07P7dUEQ3Q9tvN33gbUPMRP91epxETN24k4QlTsyFzwrnyzI2o1/o6h95jnBQyjXb9qb1Nso17SuC8PeBkJhXvJkM65lAotsR0vBclV6ni4mIl3oYIhKihyNVgFzdqz7M8FR9YxXiH6dGXyqn17unx9fvLY2tIiTlfPx+QVl3I2C0t2+f77WT1aSq2BIl0tc7+LLyae1RedjxxSqUX0/6vTHhQh52FGFjeCP2ZLb3/9GvqFrrdDavt5dS1v8JkBfREGZNgychMhPiv+TCwV3/fNmVuhiP/sAJsNSe9r8hCwa8N8YEi105lF1jAgXSLpunA7I4y3whMVJHET1y9U2QR/dGDQLS583l6uBr4fqD+iLk3+yLGHnQcuTbxFMRKoB7xuedBBhyr1IM8/VIqRWSwivt2p7ZSnw== ranie@raniel-garcia"
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
    name    = "${local.prefix}-interface"
    primary = true

    ip_configuration {
      name      = "${local.prefix}-internal"
      primary   = true
      subnet_id = azurerm_subnet.internal.id
    }
  }
}

resource "azurerm_virtual_machine_scale_set_extension" "build-agent-custom-script" {
  name                         = "${local.prefix}-vmss-extension"
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.build-agent.id
  publisher                    = "Microsoft.Azure.Extensions"
  type                         = "CustomScript"
  type_handler_version         = "2.0"
  settings = jsonencode({
    "fileUris": ["https://github.com/micro9000/My-Azure-IaC/blob/main/Temporary-Build-Agent/Azure-IaC/init_script.sh"],
    "commandToExecute" = "chmod +x ./init_script.sh && bash ./init_script.sh"
  })
}

resource "azurerm_virtual_machine_scale_set_extension" "build-agent-team-services-agent" {
  name                         = "${local.prefix}-vmss-extension"
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.build-agent.id
  publisher                    = "Microsoft.VisualStudio.Services"
  type                         = "TeamServicesAgentLinux"
  type_handler_version         = "1.23"
  settings = jsonencode({
    "isPipelinesAgent": true,
    "agentFolder": "/agent",
    "agentDownloadUrl": "https://vstsagentpackage.azureedge.net/agent/3.234.0/vsts-agent-linux-x64-3.234.0.tar.gz",
    "enableScriptDownloadUrl": "https://vstsagenttools.blob.core.windows.net/tools/ElasticPools/Linux/15/enableagent.sh"
  })
}