### RECOVERY VAULT. Uso para máquina virtuales ###

resource "azurerm_recovery_services_vault" "vault1" {
  name                = "${local.client}-RecoveryServiceVault"
  location            = local.location
  resource_group_name = azurerm_resource_group.rg-prod["Critical-Core"].name
  sku                 = "Standard"
  soft_delete_enabled = true
  immutability        = "Unlocked"
  storage_mode_type   = "ZoneRedundant"
  depends_on          = [azurerm_resource_group.rg-prod["Critical-Core"]]
  tags = merge(local.tags, {
    Recurso = "Recovery Service Vault"
  })
}

### POLITICAS DE BACKUP ###

resource "azurerm_backup_policy_vm" "policyv2" {
  name                           = "${local.client}-Policy-HourlyBackup"
  resource_group_name            = azurerm_recovery_services_vault.vault1.resource_group_name
  recovery_vault_name            = azurerm_recovery_services_vault.vault1.name
  instant_restore_retention_days = 5
  policy_type                    = "V2"

  timezone = "W. Europe Standard Time"

  backup {
    frequency     = "Hourly"
    time          = "00:00"
    hour_interval = 4
    hour_duration = 24
  }

  retention_daily {
    count = 31
  }
}

resource "azurerm_backup_policy_vm" "policyv1" {
  name                           = "${local.client}-Policy-DailyBackup"
  resource_group_name            = azurerm_recovery_services_vault.vault1.resource_group_name
  recovery_vault_name            = azurerm_recovery_services_vault.vault1.name
  instant_restore_retention_days = 3
  policy_type                    = "V1"

  timezone = "W. Europe Standard Time"

  backup {
    frequency = "Daily"
    time      = "00:00"
  }

  retention_daily {
    count = 31
  }
}

### Diagnostic settings para el Recovery Services Vault ###

resource "azurerm_monitor_diagnostic_setting" "diag_sett_vault" {
  name                           = "${local.client}-DS-Vault"
  target_resource_id             = azurerm_recovery_services_vault.vault1.id
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.law-vm.id
  log_analytics_destination_type = "Dedicated"

  enabled_log {
    #category_group = "allLogs"
    category = "AddonAzureBackupProtectedInstance"
  }
  enabled_log {
    category = "AddonAzureBackupStorage"
  }
  enabled_log {
    category = "CoreAzureBackup"
  }
  enabled_log {
    category = "AddonAzureBackupJobs"
  }
  enabled_log {
    category = "AddonAzureBackupPolicy"
  }
}

# Info: https://learn.microsoft.com/es-es/azure/azure-monitor/essentials/resource-logs-schema#service-specific-schemas
