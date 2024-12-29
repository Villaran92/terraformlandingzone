### TARJETA DE RED (NIC) ###

resource "azurerm_network_interface" "nic_linux" {
  for_each            = local.vms_linux_to_create
  name                = "${local.client}-NIC-${each.value.name}"
  location            = local.location
  resource_group_name = azurerm_resource_group.rg-prod["Critical-App"].name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_app.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = merge(local.tags, {
    Recurso          = "Tarjeta de red"
    RecursoPrincipal = "${each.value.mainresource}"
  })
}

### GRUPO DE SEGURIDAD DE RED (NSG) ###

resource "azurerm_network_security_group" "nsg_linux" {
  for_each            = local.vms_linux_to_create
  name                = "${local.client}-NSG-${each.value.name}"
  location            = local.location
  resource_group_name = azurerm_resource_group.rg-prod["Critical-App"].name

  tags = merge(local.tags, {
    Recurso          = "NSG"
    RecursoPrincipal = "${each.value.mainresource}"
  })

  depends_on = [azurerm_resource_group.rg-prod]
}

resource "azurerm_network_interface_security_group_association" "nsg_assoc_linux" {
  for_each                  = local.vms_linux_to_create
  network_interface_id      = azurerm_network_interface.nic_linux[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg_linux[each.key].id
}

### MÁQUINA VIRTUAL LINUX ###

resource "tls_private_key" "rsa-linux" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "linuxkey" {
  filename = "./keys/sshkey.pem"
  content  = tls_private_key.rsa-linux.private_key_pem
}

resource "azurerm_linux_virtual_machine" "vm_linux" {
  for_each                                               = local.vms_linux_to_create
  name                                                   = "${local.client}-VM-${each.value.name}"
  resource_group_name                                    = azurerm_resource_group.rg-prod["Critical-App"].name
  location                                               = local.location
  size                                                   = each.value.size
  admin_username                                         = "azureuser"
  patch_assessment_mode                                  = "AutomaticByPlatform"
  bypass_platform_safety_checks_on_user_schedule_enabled = true
  patch_mode                                             = "AutomaticByPlatform"
  network_interface_ids                                  = [azurerm_network_interface.nic_linux[each.key].id]
  encryption_at_host_enabled = "true"
  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.rsa-linux.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_ZRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

   identity {
    type         = "SystemAssigned"
  }

  tags = merge(local.tags, each.value.tags, {
    Recurso = "VM Linux"
    RecursoPrincipal = "${each.value.mainresource}"
  })

}
