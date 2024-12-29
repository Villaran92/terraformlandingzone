### POLICY DEFINITIONS (valores del tfvars) ###

resource "azurerm_subscription_policy_assignment" "this" {
  for_each = { for policy in var.policy_list : policy.policy_name => policy }
  name     = each.key
  # name                 = each.value.policy_name  // tambien se puede usar each.value...
  policy_definition_id = each.value.policy_id
  subscription_id      = data.azurerm_subscription.current.id

  identity {
    type = "SystemAssigned"
  }
  location = local.location
}

### POLICY DEFINITIONS (valores de policy_data.tf) ###

resource "azurerm_subscription_policy_assignment" "sql_audit" {
  name                 = "Audit SQL LAW"
  policy_definition_id = data.azurerm_policy_definition.sql_audit.id
  subscription_id      = data.azurerm_subscription.current.id
  location             = local.location
  parameters           = <<PARAMETERS
{
  "logAnalyticsWorkspaceId": {
    "value": "${data.azurerm_subscription.current.id}/resourceGroups/${azurerm_resource_group.rg-prod["Critical-Core"].name}/providers/Microsoft.OperationalInsights/workspaces/${azurerm_log_analytics_workspace.law-vm.name}"
  }
}
PARAMETERS
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.user_identity.id]
  }
}

resource "azurerm_subscription_policy_assignment" "guest_win" {
  name                 = "Windows Guest Configuration extension"
  policy_definition_id = data.azurerm_policy_definition.guest_win.id
  subscription_id      = data.azurerm_subscription.current.id
  location             = local.location
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.user_identity.id]
  }
}

resource "azurerm_subscription_policy_assignment" "guest_linux" {
  name                 = "Linux Guest Configuration extension"
  policy_definition_id = data.azurerm_policy_definition.guest_linux.id
  subscription_id      = data.azurerm_subscription.current.id
  location             = local.location
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.user_identity.id]
  }
}

resource "azurerm_subscription_policy_assignment" "locations" {
  name                 = "Allowed locations"
  policy_definition_id = data.azurerm_policy_definition.locations.id
  subscription_id      = data.azurerm_subscription.current.id
  location             = local.location
  parameters           = <<PARAMETERS
{
  "listOfAllowedLocations": {
        "value": ["${local.location}", "West Europe"]
      }
}
PARAMETERS
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.user_identity.id]
  }
}

resource "azurerm_subscription_policy_assignment" "amawin" {
  name                 = "Deploy AMA Windows"
  policy_definition_id = data.azurerm_policy_definition.amawin.id
  subscription_id      = data.azurerm_subscription.current.id
  location             = local.location
  parameters           = <<PARAMETERS
{
  "bringYourOwnUserAssignedManagedIdentity": {
    "value": true
  }
}
PARAMETERS
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.user_identity.id]
  }
}

resource "azurerm_subscription_policy_assignment" "amalinux" {
  name                 = "Deploy AMA Linux"
  policy_definition_id = data.azurerm_policy_definition.amalinux.id
  subscription_id      = data.azurerm_subscription.current.id
  location             = local.location
  parameters           = <<PARAMETERS
{
  "bringYourOwnUserAssignedManagedIdentity": {
    "value": true
  }
}
PARAMETERS
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.user_identity.id]
  }
}

resource "azurerm_subscription_policy_assignment" "deployIaaSAntimalware" {
  name                 = "Deploy Microsoft IaaSAntimalware extension for Windows Server"
  policy_definition_id = azurerm_policy_definition.IaaSAntimalware.id
  subscription_id      = data.azurerm_subscription.current.id
  location             = local.location
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.user_identity.id]
  }
  depends_on = [azurerm_policy_definition.IaaSAntimalware]
}

resource "azurerm_subscription_policy_assignment" "assign_sql_private_endpoint" {
  name                 = "Ensure Private Endpoint for SQL Server"
  policy_definition_id = data.azurerm_policy_definition.sqlpe.id
  subscription_id      = data.azurerm_subscription.current.id
  location             = local.location
  parameters           = <<PARAMETERS
    {
      "privateEndpointSubnetId": {
        "value": "${data.azurerm_subscription.current.id}/resourceGroups/${azurerm_resource_group.rg-prod["Critical-Core"].name}/providers/Microsoft.Network/virtualNetworks/${azurerm_virtual_network.vnet_core.name}/subnets/${azurerm_subnet.subnet_pe.name}"
      }
    }
  PARAMETERS
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.user_identity.id]
  }
  depends_on = [azurerm_subnet.subnet_pe]
}

resource "azurerm_subscription_policy_assignment" "backup" {
  name                 = "Configure Backup in VM with given tag"
  display_name         = "Configure Backup in VM with given tag"
  policy_definition_id = data.azurerm_policy_definition.backupvm.id
  subscription_id      = data.azurerm_subscription.current.id
  location             = local.location
  parameters           = <<PARAMETERS
    {
      "vaultlocation": {
        "value": "${local.location}"
      },
      "backupPolicyId": {
        "value": "${azurerm_backup_policy_vm.policyv1.id}"
      },
      "inclusionTagName": {
        "value": "Backup"
      },
      "inclusionTagValue": {
        "value": ["Standard"]
      }
    }
    PARAMETERS
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.user_identity.id]
  }
  depends_on = [azurerm_recovery_services_vault.vault1, azurerm_backup_policy_vm.policyv1]
}

resource "azurerm_subscription_policy_assignment" "dcr" {
  name                 = "Configure Windows Machines with a DCR"
  policy_definition_id = data.azurerm_policy_definition.dcrvm.id
  subscription_id      = data.azurerm_subscription.current.id
  parameters = jsonencode({
    "dcrResourceId" = {
      "value" = "${data.azurerm_subscription.current.id}/resourceGroups/${azurerm_resource_group.rg-prod["Critical-Core"].name}/providers/Microsoft.Insights/dataCollectionRules/${azurerm_monitor_data_collection_rule.dcrlogs.id}"
    }
  })
  identity {
    type = "SystemAssigned"
  }
  location   = local.location
  depends_on = [azurerm_monitor_data_collection_rule.dcrlogs]
}

resource "azurerm_subscription_policy_assignment" "assign_sa_private_endpoint" {
  name                 = "Ensure Private Endpoint for Storage Account"
  policy_definition_id = data.azurerm_policy_definition.sape.id
  subscription_id      = data.azurerm_subscription.current.id
  location             = local.location
  parameters           = <<PARAMETERS
    {
      "privateEndpointSubnetId": {
        "value": "${data.azurerm_subscription.current.id}/resourceGroups/${azurerm_resource_group.rg-prod["Critical-Core"].name}/providers/Microsoft.Network/virtualNetworks/${azurerm_virtual_network.vnet_core.name}/subnets/${azurerm_subnet.subnet_pe.name}"
      }
    }
  PARAMETERS
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.user_identity.id]
  }
  depends_on = [azurerm_subnet.subnet_pe]
}

### OTRO EJEMPLO DE POLICY DEFINITION ###

# resource "azurerm_subscription_policy_assignment" "this" {
#   name                 = data.azurerm_policy_definition.this.display_name
#   policy_definition_id = data.azurerm_policy_definition.this.id
#   subscription_id      = local.subscription_to_assign_policy
#   parameters = jsonencode({
#     "Effect" = {
#       "value" = "AuditIfNotExists"
#     }
#     "requiredRetentionDays" = {
#       "value" = "90"
#     }
#   })
# }

##########################################