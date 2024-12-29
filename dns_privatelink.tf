### ZONAS DNS PRIVADAS PARA PRIVATE LINK ###

resource "azurerm_private_dns_zone" "this" {
  for_each            = var.private_endpoint
  name                = each.value.name
  resource_group_name = azurerm_resource_group.rg-prod["Critical-Core"].name
  tags = merge(local.tags, {
    Recurso = "Zona DNS Privada"
  })
}
