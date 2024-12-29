### GRUPOS PARA ENTRA ID ###

resource "azuread_group" "sqladmingroup" {
  display_name     = "SQL Group Admins"
  security_enabled = true
}

resource "azuread_group" "windowslogingroup" {
  display_name     = "Windows Login Group Admins"
  security_enabled = true
}

resource "azuread_group" "keyvaultsecretgroup" {
  display_name     = "Key Vault Secret Group Admins"
  security_enabled = true
}


