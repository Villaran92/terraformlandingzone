variable "cliente" {
  type        = string
  description = "Código de cliente con 3 letras en mayúsculas"

  validation {
    condition     = length(var.cliente) == 3
    error_message = "El valor de 'cliente' debe tener exactamente 3 letras."
  }
}

variable "client_id" {
  type      = string
  sensitive = true
}

variable "client_secret" {
  type      = string
  sensitive = true
}

variable "subscription_id" {
  type      = string
  sensitive = true
}

variable "tenant_id" {
  type      = string
  sensitive = true
}

variable "test" {
  type = bool
}

variable "vnet" {
  type = list(string)
}

variable "subnet_core" {
  type = list(string)
}

variable "subnet_app" {
  type = list(string)
}

variable "subnet_external" {
  type = list(string)
}

variable "subnet_pe" {
  type = list(string)
}

variable "subnet_bastion" {
  type = list(string)
}

variable "create_linux_vms" {
  type = bool
}

variable "create_win_vms" {
  type = bool
}

variable "create_database" {
  type = bool
}

variable "resource_group_principal" {
  type = list(string)
}

variable "vms_linux" {
  type = map(object({
    name         = string
    size         = string
    mainresource = string
    tags         = map(string)
  }))
}

variable "vms_windows" {
  type = map(object({
    name         = string
    size         = string
    mainresource = string
    tags         = map(string)
  }))
}

variable "dbserver_mssql" {
  type = map(object({
    name = string
  }))
}

variable "alert_configs" {
  type = map(object({
    description          = string
    metric_name          = string
    operator             = string
    aggregation          = string
    threshold            = number
    target_resource_type = string
    metric_namespace     = string
    severity             = number
    frequency            = string
  }))
}

variable "policy_list" {
  type = list(object({
    policy_id   = string
    policy_name = string
  }))
}

variable "private_endpoint" {
  type = map(object({
    name = string
  }))
}

variable "windows_event_log" {
  type = list(object({
    streams        = list(string)
    x_path_queries = list(string)
    name           = string
  }))
}

variable "mailalerts" {
  type = map(object({
    email_address           = string
    use_common_alert_schema = bool
  }))
}

variable "displayName" {
  type        = string
  description = "email para Teams"
}
