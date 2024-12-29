### TARJETA DE RED (NIC) ###

resource "azurerm_network_interface" "nic_win" {
  for_each            = local.vms_win_to_create
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

resource "azurerm_network_security_group" "nsg_win" {
  for_each            = local.vms_win_to_create
  name                = "${local.client}-NSG-${each.value.name}"
  location            = local.location
  resource_group_name = azurerm_resource_group.rg-prod["Critical-App"].name

  tags = merge(local.tags, {
    Recurso          = "NSG"
    RecursoPrincipal = "${each.value.mainresource}"
  })
}

resource "azurerm_network_interface_security_group_association" "nsg_assoc_win" {
  for_each                  = local.vms_win_to_create
  network_interface_id      = azurerm_network_interface.nic_win[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg_win[each.key].id
}

### MÁQUINA VIRTUAL WINDOWS ###

resource "azurerm_windows_virtual_machine" "vm_windows" {
  for_each                                               = local.vms_win_to_create
  name                                                   = "${local.client}-VM-${each.value.name}"
  resource_group_name                                    = azurerm_resource_group.rg-prod["Critical-App"].name
  location                                               = local.location
  size                                                   = each.value.size
  admin_username                                         = "azureuser"
  admin_password                                         = random_password.password.result
  patch_assessment_mode                                  = "AutomaticByPlatform"
  bypass_platform_safety_checks_on_user_schedule_enabled = true
  patch_mode                                             = "AutomaticByPlatform"

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.user_identity.id]
  }

  network_interface_ids = [azurerm_network_interface.nic_win[each.key].id]
  encryption_at_host_enabled = "true"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_ZRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  tags = merge(local.tags, each.value.tags, {
    Recurso = "VM Windows"
    RecursoPrincipal = "${each.value.mainresource}"
  })
  hotpatching_enabled = false
  depends_on          = [azurerm_key_vault_secret.vm_password, azurerm_virtual_network.vnet_core]
}
