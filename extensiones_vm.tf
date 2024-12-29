### EXTENSIONES VMs ###

resource "azurerm_virtual_machine_extension" "aad_login" {
  for_each                   = local.vms_win_to_create
  name                       = "AADLoginForWindows"
  virtual_machine_id         = "${data.azurerm_subscription.current.id}/resourceGroups/${azurerm_resource_group.rg-prod["Critical-App"].name}/providers/Microsoft.Compute/virtualMachines/${local.client}-VM-${each.value.name}"
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "2.2"
  depends_on                 = [azurerm_windows_virtual_machine.vm_windows]
  auto_upgrade_minor_version = true
}

resource "azurerm_virtual_machine_extension" "ama" {
  for_each                   = local.vms_win_to_create
  name                       = "AzureMonitorWindowsAgent"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.14"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm_windows[each.key].id
}

resource "azurerm_virtual_machine_extension" "amalinux" {
  for_each                   = local.vms_linux_to_create
  name                       = "AzureMonitorLinuxAgent"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.33"
  virtual_machine_id         = azurerm_linux_virtual_machine.vm_linux[each.key].id
}
