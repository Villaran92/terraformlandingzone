##### ENTORNO DE TESTEO. PARA CAMBIAR VALORES CONTACTAR CON ADMINISTRADOR #####

# Crear RG para testeo

resource "azurerm_resource_group" "rg-test" {
  count    = var.test ? 1 : 0
  location = local.location
  name     = "RG-TEST"
  tags = merge(local.tags, {
    Recurso = "Grupo de recursos",
    Entorno = "Test"
  })
}

# Crear VNET para testeo

resource "azurerm_virtual_network" "vnet-test" {
  count               = var.test ? 1 : 0
  name                = "VNET-TEST"
  location            = local.location
  resource_group_name = azurerm_resource_group.rg-test[0].name
  address_space       = ["10.0.0.0/16"]

  tags = merge(local.tags, {
    Recurso = "Red Virtual"
    Entorno = "Test"
  })
}

resource "azurerm_subnet" "subnet_test" {
  count                           = var.test ? 1 : 0
  name                            = "TestSubnet"
  resource_group_name             = azurerm_resource_group.rg-test[0].name
  virtual_network_name            = azurerm_virtual_network.vnet-test[0].name
  address_prefixes                = ["10.0.0.0/24"]
  default_outbound_access_enabled = true
}

# NIC Y NSG para testeo

resource "azurerm_network_interface" "nic_win_test" {
  count               = var.test ? 1 : 0
  name                = "NIC-TEST"
  location            = local.location
  resource_group_name = azurerm_resource_group.rg-test[0].name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_test[0].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.testpip[0].id
  }

  tags = merge(local.tags, {
    Recurso = "Tarjeta de red"
    Entorno = "Test"
  })

}

resource "azurerm_network_security_group" "nsg_win_test" {
  count               = var.test ? 1 : 0
  name                = "NSG-TEST"
  location            = local.location
  resource_group_name = azurerm_resource_group.rg-test[0].name

  tags = merge(local.tags, {
    Recurso = "NSG"
    Entorno = "Test"
  })
}

resource "azurerm_network_interface_security_group_association" "nsg_assoc_win_test" {
  count                     = var.test ? 1 : 0
  network_interface_id      = azurerm_network_interface.nic_win_test[0].id
  network_security_group_id = azurerm_network_security_group.nsg_win_test[0].id
}

# IP publica para testeo

resource "azurerm_public_ip" "testpip" {
  count               = var.test ? 1 : 0
  name                = "PIP-TEST"
  resource_group_name = azurerm_resource_group.rg-test[0].name
  location            = local.location
  allocation_method   = "Static"

  tags = merge(local.tags, {
    Recurso = "IP publica"
    Entorno = "Test"
  })
}

### MÁQUINA VIRTUAL WINDOWS ###

resource "azurerm_windows_virtual_machine" "vm_windows_test" {
  count                 = var.test ? 1 : 0
  name                  = "VM-TEST"
  resource_group_name   = azurerm_resource_group.rg-test[0].name
  location              = local.location
  size                  = "Standard_B1ls"
  admin_username        = "azureuser"
  admin_password        = "Password1234!"
  network_interface_ids = [azurerm_network_interface.nic_win_test[0].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  tags = merge(local.tags, {
    Recurso = "VM Windows"
    Entorno = "Test"
  })

}
