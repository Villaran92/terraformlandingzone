### DISCO DE DATOS PARA WINDOWS ###

resource "azurerm_managed_disk" "data_disk" {
  for_each             = local.vms_win_to_create
  name                 = "${local.client}-DATA-DISK-${each.value.name}"
  location             = local.location
  resource_group_name  = azurerm_resource_group.rg-prod["Critical-App"].name
  storage_account_type = "StandardSSD_ZRS"
  create_option        = "Empty"
  disk_size_gb         = "128"

  tags = merge(local.tags, {
    Recurso          = "Disco de datos"
    RecursoPrincipal = "${each.value.mainresource}"
  })

  depends_on = [azurerm_resource_group.rg-prod]
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk_assoc" {
  for_each           = local.vms_win_to_create
  managed_disk_id    = azurerm_managed_disk.data_disk[each.key].id
  virtual_machine_id = azurerm_windows_virtual_machine.vm_windows[each.key].id
  lun                = "10"
  caching            = "ReadWrite"

  depends_on = [azurerm_windows_virtual_machine.vm_windows]
}
