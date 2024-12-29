### GENERAR PASSWORD ###

# Generar una contraseña aleatoria solo una vez
resource "random_password" "password" {
  length           = 16
  special          = true
  upper            = true
  lower            = true
  numeric          = true
  override_special = "!@#$%^&*()-_=+[]{}|;:,.<>?/`~"
  keepers = {
    # La contraseña solo cambiará si la clave cambia (por ejemplo, si se cambia el nombre del recurso)
    "keeper" = "password_no_cambiar"
  }
  min_lower   = 1
  min_numeric = 1
  min_special = 1
  min_upper   = 1
}

### KEY VAULT ###
resource "azurerm_key_vault" "keyvault" {
  name                      = "${local.client}-KeyVault-Principal"
  location                  = local.location
  resource_group_name       = azurerm_resource_group.rg-prod["Critical-Core"].name
  sku_name                  = "standard"
  tenant_id                 = data.azurerm_client_config.tenant.tenant_id
  enable_rbac_authorization = true
  depends_on                = [azurerm_resource_group.rg-prod]
  tags = merge(local.tags, {
    Recurso = "Key Vault"
  })
}

### VAULT DE SECRETOS ###

resource "azurerm_key_vault_secret" "vm_password" {
  name         = "vm-password"
  value        = random_password.password.result
  key_vault_id = azurerm_key_vault.keyvault.id
  depends_on   = [azurerm_role_assignment.rolekeyvaultsecretofficer]
}

resource "azurerm_key_vault_secret" "vm_password_linux" {
  name         = "vm-password-linux"
  value        = tls_private_key.rsa-linux.private_key_pem
  key_vault_id = azurerm_key_vault.keyvault.id
  depends_on   = [azurerm_role_assignment.rolekeyvaultsecretofficer]
}
