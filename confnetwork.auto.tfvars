### NETWORK ###

vnet            = ["10.0.0.0/16"]
subnet_app      = ["10.0.2.0/24"]
subnet_bastion  = ["10.0.100.0/27"]
subnet_core     = ["10.0.1.0/24"]
subnet_external = ["10.0.3.0/24"]
subnet_pe       = ["10.0.4.0/24"]

### DNS FOR PRIVATE ENDPOINT ###

private_endpoint = {
  "sql" = {
    name = "privatelink.database.windows.net"
  },
  "sa" = {
    name = "privatelink.blob.core.windows.net"
  }
}
