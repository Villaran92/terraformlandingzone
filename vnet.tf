### VIRTUAL NETWORK ###

resource "azurerm_virtual_network" "vnet_core" {
  name                = "${local.client}-VNET-Core"
  location            = local.location
  resource_group_name = azurerm_resource_group.rg-prod["Critical-Core"].name
  address_space       = var.vnet
  tags = merge(local.tags, {
    Recurso = "Red Virtual"
  })

  depends_on = [azurerm_resource_group.rg-prod]
}

### SUBNETS ###

resource "azurerm_subnet" "subnet_core" {
  name                            = "CoreSubnet"
  resource_group_name             = azurerm_virtual_network.vnet_core.resource_group_name
  virtual_network_name            = azurerm_virtual_network.vnet_core.name
  address_prefixes                = var.subnet_core
  default_outbound_access_enabled = false
}

resource "azurerm_subnet" "subnet_app" {
  name                            = "AppSubnet"
  resource_group_name             = azurerm_virtual_network.vnet_core.resource_group_name
  virtual_network_name            = azurerm_virtual_network.vnet_core.name
  address_prefixes                = var.subnet_app
  default_outbound_access_enabled = false
}

resource "azurerm_subnet" "subnet_external" {
  name                            = "ExternalSubnet"
  resource_group_name             = azurerm_virtual_network.vnet_core.resource_group_name
  virtual_network_name            = azurerm_virtual_network.vnet_core.name
  address_prefixes                = var.subnet_external
  default_outbound_access_enabled = true
}

resource "azurerm_subnet" "subnet_pe" {
  name                            = "PrivateEndpointSubnet"
  resource_group_name             = azurerm_virtual_network.vnet_core.resource_group_name
  virtual_network_name            = azurerm_virtual_network.vnet_core.name
  address_prefixes                = var.subnet_pe
  default_outbound_access_enabled = false
}

### AZURE BASTION ###

resource "azurerm_subnet" "subnet_bastion" {
  name                            = "AzureBastionSubnet"
  resource_group_name             = azurerm_virtual_network.vnet_core.resource_group_name
  virtual_network_name            = azurerm_virtual_network.vnet_core.name
  address_prefixes                = var.subnet_bastion
  default_outbound_access_enabled = false
}

resource "azurerm_bastion_host" "this" {
  name                = "${local.client}-Bastion"
  location            = local.location
  resource_group_name = azurerm_resource_group.rg-prod["Critical-Core"].name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.subnet_bastion.id
    public_ip_address_id = azurerm_public_ip.bastionpip.id
  }
  tags = merge(local.tags, {
    Recurso = "Bastion"
  })
}

resource "azurerm_public_ip" "bastionpip" {
  name                = "${local.client}-Bastion-PIP"
  location            = local.location
  resource_group_name = azurerm_resource_group.rg-prod["Critical-Core"].name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = merge(local.tags, {
    Recurso = "IP publica Bastion"
  })
}

### NAT GATEWAY ###

resource "azurerm_nat_gateway" "this" {
  name                    = "${local.client}-NAT-Principal"
  location                = local.location
  resource_group_name     = azurerm_resource_group.rg-prod["Critical-Core"].name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10

  tags = merge(local.tags, {
    Recurso = "NAT Gateway"
  })
}

resource "azurerm_public_ip" "pip-nat" {
  name                = "${local.client}-PIP-NATGateway"
  location            = local.location
  resource_group_name = azurerm_resource_group.rg-prod["Critical-Core"].name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = merge(local.tags, {
    Recurso = "IP publica NAT"
  })
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  nat_gateway_id       = azurerm_nat_gateway.this.id
  public_ip_address_id = azurerm_public_ip.pip-nat.id
}

resource "azurerm_subnet_nat_gateway_association" "nat-assoc-appsubnet" {
  subnet_id      = azurerm_subnet.subnet_app.id
  nat_gateway_id = azurerm_nat_gateway.this.id
}

resource "azurerm_subnet_nat_gateway_association" "nat-assoc-coresubnet" {
  subnet_id      = azurerm_subnet.subnet_core.id
  nat_gateway_id = azurerm_nat_gateway.this.id
}

