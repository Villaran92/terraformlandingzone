### CUSTOM ALERTS ###

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "almacenamientobajo" {
  name                  = "Almacenamiento Bajo"
  resource_group_name   = azurerm_resource_group.rg-prod["Critical-Core"].name
  location              = local.location
  evaluation_frequency  = "PT5M"
  window_duration       = "PT5M"
  scopes                = [data.azurerm_subscription.current.id]
  target_resource_types = ["Microsoft.Compute/virtualMachines"]
  severity              = 1
  criteria {
    query                   = <<-QUERY
      InsightsMetrics
      | where Origin == "vm.azm.ms"
      | where Namespace == "LogicalDisk" and Name == "FreeSpacePercentage"
      | extend Disk=tostring(todynamic(Tags)["vm.azm.ms/mountId"])
      | where Disk in ('C:') or Disk in ('/')
      | summarize AggregatedValue = avg(Val) by bin(TimeGenerated, 10m), Computer, _ResourceId, Disk
      QUERY
    time_aggregation_method = "Average"
    threshold               = 20
    operator                = "LessThan"
    resource_id_column      = "_ResourceId"
    metric_measure_column   = "AggregatedValue"
    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  auto_mitigation_enabled          = true
  workspace_alerts_storage_enabled = false
  description                      = "Almacenamiento bajo VM disco OS"
  display_name                     = "Almacenamiento bajo VM disco OS"
  enabled                          = true
  query_time_range_override        = "PT1H"
  skip_query_validation            = true
  action {
    action_groups = [azurerm_monitor_action_group.actiongroupsistemas.id]
  }
  tags = merge(local.tags, {
    Recurso = "Alertas"
  })
}
