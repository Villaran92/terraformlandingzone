### PERFIL DE MANTENIMIENTO ###

resource "azurerm_maintenance_configuration" "updateconfig" {
  name                     = "${local.client}-UpdateConfig"
  resource_group_name      = azurerm_resource_group.rg-prod["Critical-Core"].name
  location                 = local.location
  scope                    = "InGuestPatch"
  in_guest_user_patch_mode = "User"
  window {
    start_date_time = "${formatdate("YYYY-MM-DD", timestamp())} 00:00"
    time_zone       = "Romance Standard Time"
    recur_every     = "Week Saturday"
    # recur_every = "Month Second Saturday"
  }
  install_patches {
    reboot = "IfRequired"
    windows {
      classifications_to_include = ["Critical", "Security"]
      kb_numbers_to_exclude      = []
      kb_numbers_to_include      = []
    }
    linux {
      classifications_to_include = ["Critical", "Security"]
    }
  }
  tags = merge(local.tags, {
    Recurso = "Perfil mantenimiento"
  })
}

### ASIGNACION DE MANTENIMIENTO ###

resource "azurerm_maintenance_assignment_dynamic_scope" "updateconfig" {
  name                         = "${local.client}-UpdateScope-Weekly"
  maintenance_configuration_id = azurerm_maintenance_configuration.updateconfig.id

  filter {
    locations       = ["${local.location}"]
    os_types        = ["Windows", "Linux"]
    resource_groups = [for rg in var.resource_group_principal : rg]
    resource_types  = ["Microsoft.Compute/virtualMachines"]
    tag_filter      = "Any"
    tags {
      tag    = "updateProfile"
      values = ["Weekly"]
    }
    # tags {
    #   tag    = "xxx"
    #   values = ["xxx"]
    # }
  }
}

# Informacion adicional:
# https://www.letsdodevops.com/p/lets-do-devops-azure-dynamic-scopes
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/maintenance_assignment_dynamic_scope
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/maintenance_configuration#windows-1
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine
# https://learn.microsoft.com/en-us/azure/update-manager/tutorial-dynamic-grouping-for-scheduled-patching?tabs=avms%2Caz-portal
# https://learn.microsoft.com/en-us/azure/update-manager/manage-dynamic-scoping?tabs=avms%2Cvm
