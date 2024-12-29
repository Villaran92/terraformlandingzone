# AZURE POLICY con configuracion concreta. Los valores sirven de referencia para policy.tf #

data "azurerm_policy_definition" "sqlpe" {
  display_name = "Configure Azure SQL Server to enable private endpoint connections"
}

data "azurerm_policy_definition" "backupvm" {
  display_name = "Configure backup on virtual machines with a given tag to an existing recovery services vault in the same location"
}

data "azurerm_policy_definition" "amalinux" {
  display_name = "Configure Linux virtual machines to run Azure Monitor Agent with user-assigned managed identity-based authentication"
}

data "azurerm_policy_definition" "amawin" {
  display_name = "Configure Windows virtual machines to run Azure Monitor Agent with user-assigned managed identity-based authentication"
}

data "azurerm_policy_definition" "locations" {
  display_name = "Allowed locations"
}

data "azurerm_policy_definition" "guest_win" {
  display_name = "Deploy the Windows Guest Configuration extension to enable Guest Configuration assignments on Windows VMs"
}

data "azurerm_policy_definition" "guest_linux" {
  display_name = "Deploy the Linux Guest Configuration extension to enable Guest Configuration assignments on Linux VMs"
}

data "azurerm_policy_definition" "sql_audit" {
  display_name = "Configure SQL servers to have auditing enabled to Log Analytics workspace"
}

data "azurerm_policy_definition" "dcrvm" {
  display_name = "Configure Windows Machines to be associated with a Data Collection Rule or a Data Collection Endpoint"
}

data "azurerm_policy_definition" "sape" {
  display_name = "Configure Storage account to use a private link connection"
}
