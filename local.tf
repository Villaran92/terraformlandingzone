### VALORES LOCALES ###

locals {
  # Localizacion principal de los recursos
  location = "Spain Central"
  # Iniciales del cliente, en MAY y 3 carácteres
  client = upper(var.cliente)
  # Etiquetas para añadir en todos los recursos
  tags = {
    "Source" = "Terraform"
  }
}

locals {
  vms_linux_to_create = var.create_linux_vms ? var.vms_linux : {}
}

locals {
  vms_win_to_create = var.create_win_vms ? var.vms_windows : {}
}

locals {
  dbserver_to_create = var.create_database ? var.dbserver_mssql : {}
}
