### GRUPO DE RECURSOS ###

resource "azurerm_resource_group" "rg-prod" {
  for_each = toset(var.resource_group_principal)
  name     = each.key
  location = local.location
  tags = merge(local.tags, {
    Recurso = "Grupo de recursos"
    Entorno = "Produccion"
  })
}
