# Configuracion alertas

### GRUPO DE ACCION ###

mailalerts = {
  "sistemas" = {
    email_address           = "sistemas@sistemas.com"
    use_common_alert_schema = true
  }
  "seguridad" = {
    email_address           = "seguridad@seguridad.com"
    use_common_alert_schema = true
  }
}

### EMAIL PARA TEAMS ###

displayName = "soporte@soporte.com"

### ALERTAS ###

alert_configs = {
  "High CPU" = {
    description          = "CPU usage is above 95%."
    metric_name          = "Percentage CPU"
    operator             = "GreaterThan" // GreaterThan, LessThan, EqualTo, GreaterThanOrEqual, LessThanOrEqual
    aggregation          = "Average"
    threshold            = 95
    target_resource_type = "Microsoft.Compute/virtualMachines"
    metric_namespace     = "Microsoft.Compute/virtualMachines"
    severity             = 1
    frequency            = "PT5M"
  }
  "High Write Operations" = {
    description          = "Disk Write Operations/Sec is above 100."
    metric_name          = "Disk Write Operations/Sec"
    operator             = "GreaterThan"
    aggregation          = "Average"
    threshold            = 100
    target_resource_type = "Microsoft.Compute/virtualMachines"
    metric_namespace     = "Microsoft.Compute/virtualMachines"
    severity             = 2
    frequency            = "PT5M"
  }
  "Available Memory" = {
    description          = "Memory less than 1GB."
    metric_name          = "Available Memory Bytes"
    operator             = "LessThan"
    aggregation          = "Average"
    threshold            = 1024
    target_resource_type = "Microsoft.Compute/virtualMachines"
    metric_namespace     = "Microsoft.Compute/virtualMachines"
    severity             = 1
    frequency            = "PT5M"
  }
}

######### DCR #########

windows_event_log = [{
  streams        = ["Microsoft-WindowsEvent"]
  x_path_queries = ["*![System/Level=1]"]
  name           = "example-datasource-wineventlog"
  },
  {
    streams        = ["Microsoft-WindowsEvent"]
    x_path_queries = ["Application!*[System[(Level=1 or Level=2)]]"]
    name           = "example-datasource-wineventlog1"
  },
  {
    streams        = ["Microsoft-WindowsEvent"]
    x_path_queries = ["Security!*[System[(band(Keywords,13510798882111488) and (EventID=4624 or EventID=4625 or EventID=4720 or EventID=4728 or EventID=4732 or EventID=4756 or EventID=1102 or EventID=4740 or EventID=4663 or EventID=4741))]]"]
    name           = "example-datasource-wineventlog2"
}]
