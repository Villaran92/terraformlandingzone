### INSIGHTS ###

resource "azurerm_monitor_data_collection_rule" "this" {
  name                = "MSVMI-${local.client}-DCR"
  resource_group_name = azurerm_resource_group.rg-prod["Critical-Core"].name
  location            = local.location

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.law-vm.id
      name                  = "VMInsightsPerf-Logs-Dest"
    }
  }

  data_flow {
    streams      = ["Microsoft-InsightsMetrics"]
    destinations = ["VMInsightsPerf-Logs-Dest"]
  }

  data_sources {
    performance_counter {
      streams                       = ["Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 60
      counter_specifiers            = ["\\VmInsights\\DetailedMetrics"]
      name                          = "VMInsightsPerfCounters"
    }
  }
  tags = merge(local.tags, {
    Recurso = "Data Collection Rule"
  })
  depends_on = [azurerm_log_analytics_workspace.law-vm]
}

resource "azurerm_monitor_data_collection_rule_association" "vminsightswin" {
  for_each                = local.vms_win_to_create
  name                    = "insights-windows"
  data_collection_rule_id = azurerm_monitor_data_collection_rule.this.id
  description             = "Monitor data collection rule"
  target_resource_id      = azurerm_windows_virtual_machine.vm_windows[each.key].id
}

resource "azurerm_monitor_data_collection_rule_association" "vminsightslinux" {
  for_each                = local.vms_linux_to_create
  name                    = "insights-linux"
  data_collection_rule_id = azurerm_monitor_data_collection_rule.this.id
  description             = "Monitor data collection rule"
  target_resource_id      = azurerm_linux_virtual_machine.vm_linux[each.key].id
}

### WINDOWS ###

resource "azurerm_monitor_data_collection_rule" "dcrlogs" {
  name                = "${local.client}-DCR-VM-Logs"
  resource_group_name = azurerm_resource_group.rg-prod["Critical-Core"].name
  location            = local.location
  kind                = "Windows"

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.law-vm.id
      name                  = "destination-log" # Ensure this matches the destination in `data_flow`
    }
  }

  data_flow {
    streams      = ["Microsoft-Event"]
    destinations = ["destination-log"]
  }

  data_sources {
    dynamic "windows_event_log" {
      for_each = var.windows_event_log
      content {
        streams        = windows_event_log.value.streams
        x_path_queries = windows_event_log.value.x_path_queries
        name           = windows_event_log.value.name
      }
    }

  }

  # data_sources {
  #   windows_event_log {
  #     streams        = ["Microsoft-WindowsEvent"]
  #     x_path_queries = ["*![System/Level=1]"]
  #     name           = "example-datasource-wineventlog"
  #   }
  # }

  tags = merge(local.tags, {
    Recurso = "Data Collection Rule"
  })
  depends_on = [azurerm_log_analytics_workspace.law-vm]
}

### ACTION GROUP ###

resource "azurerm_monitor_action_group" "actiongroupsistemas" {
  name                = "Sistemas y Seguridad"
  resource_group_name = azurerm_resource_group.rg-prod["Critical-Core"].name
  short_name          = "Sistemas"

  dynamic "email_receiver" {
    for_each = var.mailalerts
    content {
      email_address           = email_receiver.value.email_address
      name                    = email_receiver.key
      use_common_alert_schema = email_receiver.value.use_common_alert_schema
    }
  }

  logic_app_receiver {
    name                    = "Logic Apps Teams"
    resource_id             = data.azurerm_logic_app_workflow.logicappteams.id
    callback_url            = "https://logicapptriggerurl/..."
    use_common_alert_schema = true
  }

  tags = merge(local.tags, {
    Recurso = "Grupo de accion"
  })

}

### ALERTS ###

resource "azurerm_monitor_metric_alert" "metricalertsvm" {
  for_each                 = var.alert_configs
  name                     = each.key
  resource_group_name      = azurerm_resource_group.rg-prod["Critical-Core"].name
  scopes                   = [data.azurerm_subscription.current.id]
  target_resource_type     = each.value.target_resource_type
  target_resource_location = local.location
  description              = each.value.description
  enabled                  = false
  severity                 = each.value.severity
  frequency                = each.value.frequency

  criteria {
    metric_namespace = each.value.metric_namespace
    metric_name      = each.value.metric_name
    aggregation      = each.value.aggregation
    operator         = each.value.operator
    threshold        = each.value.threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.actiongroupsistemas.id
  }

  tags = merge(local.tags, {
    Recurso = "Alertas"
  })
}

#### ALERT PROCESSING RULES ###

resource "azurerm_monitor_alert_processing_rule_action_group" "processingrulebackup" {
  name                 = "Alerta_Backups"
  resource_group_name  = azurerm_resource_group.rg-prod["Critical-Core"].name
  scopes               = [azurerm_recovery_services_vault.vault1.id]
  add_action_group_ids = [azurerm_monitor_action_group.actiongroupsistemas.id]

  schedule {
    recurrence {
      weekly {
        days_of_week = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
      }
    }
  }

  tags = merge(local.tags, {
    Recurso = "Procesamiento de alertas"
  })
}

### INSIGHTS TEST ###

resource "azurerm_monitor_data_collection_rule" "this2" {
  name                = "MSVMI-${local.client}-DCR2"
  resource_group_name = azurerm_resource_group.rg-prod["Critical-Core"].name
  location            = local.location

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.law-vm.id
      name                  = "VMInsightsPerf-Logs-Dest2"
    }
  }

  data_flow {
    streams      = ["Microsoft-InsightsMetrics"]
    destinations = ["VMInsightsPerf-Logs-Dest2"]
  }

  data_sources {
    performance_counter {
      streams                       = ["Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 60
      counter_specifiers            = ["\\VmInsights\\DetailedMetrics"]
      name                          = "VMInsightsPerfCounters"
    }
  }

  depends_on = [azurerm_log_analytics_workspace.law-vm]
}

###
