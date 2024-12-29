### SERVIDORES BASE DE DATOS SQL SERVER PAAS ###

resource "azurerm_mssql_server" "dbserver1" {
  for_each                      = local.dbserver_to_create
  name                          = lower("${local.client}dbserver${each.value.name}")
  resource_group_name           = azurerm_resource_group.rg-prod["Critical-App"].name
  location                      = local.location
  version                       = "12.0"
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false
  administrator_login           = "azureuser"
  administrator_login_password  = random_password.password.result
  azuread_administrator {
    azuread_authentication_only = false
    login_username              = azuread_group.sqladmingroup.display_name
    object_id                   = azuread_group.sqladmingroup.object_id
  }
  tags = merge(local.tags, {
    Recurso = "Database Server"
  })
}
