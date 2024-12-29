### API ###

resource "azurerm_resource_group_template_deployment" "apitemplate" {
  name                = "teamstemplate"
  resource_group_name = azurerm_resource_group.rg-prod["Critical-Core"].name
  deployment_mode     = "Incremental"
  template_content    = file("./templates/apiteams.json")
  parameters_content = jsonencode({
    "location" = {
      value = local.location
    }
    "rg" = {
      value = azurerm_resource_group.rg-prod["Critical-Core"].name
    }
    "displayName" = {
      value = var.displayName
    }
  })
  lifecycle {
    ignore_changes = all
  }
}

### LOGIC APP ###

resource "azurerm_resource_group_template_deployment" "logicapptemplate" {
  name                = "logicapptemplate"
  resource_group_name = azurerm_resource_group.rg-prod["Critical-Core"].name
  deployment_mode     = "Incremental"
  template_content    = file("./templates/logicappsteams.json")
  parameters_content = jsonencode({
    "workflows_thklogicappsalerts_name" = {
      value = "${local.client}-LogicApps-Teams"
    }
    "location" = {
      value = lower(replace(local.location, " ", ""))
    }
    "connections_teams_externalid" = {
      value = "${data.azurerm_subscription.current.id}/resourceGroups/${azurerm_resource_group.rg-prod["Critical-Core"].name}/providers/Microsoft.Web/connections/teams"
    }
    "connections_teams_name" = {
      value = "teams"
    }
  })
  depends_on = [azurerm_resource_group_template_deployment.apitemplate]
  lifecycle {
    ignore_changes = all
  }
}

data "azurerm_logic_app_workflow" "logicappteams" {
  name                = "${local.client}-LogicApps-Teams"
  resource_group_name = azurerm_resource_group.rg-prod["Critical-Core"].name
  depends_on          = [azurerm_resource_group_template_deployment.logicapptemplate]
}

# Info
# https://www.returngis.net/2021/04/como-desplegar-azure-logic-apps-con-terraform/
