### VM LINUX ###

vms_linux = {
  "linuxtest" = {
    name         = "IIS"
    size         = "Standard_B1ms"
    mainresource = "Linux IIS"
    tags = {
      Environment   = "Production"
      Backup        = "Standard"
      updateProfile = "Weekly"
    }
  }
}

### VM WINDOWS ###

vms_windows = {
  "vm1" = {
    name         = "WIN",
    size         = "Standard_B2s"
    mainresource = "Windows Test 1"
    tags = {
      Environment   = "Production"
      Backup        = "Standard"
      updateProfile = "NA"
    }
  }
  "vm2" = {
    name         = "WIN2",
    size         = "Standard_B2s"
    mainresource = "Windows Test 2"
    tags = {
      Environment   = "Production"
      Backup        = "NA"
      updateProfile = "Weekly"
    }
  }
}

### DB SERVERS ###

dbserver_mssql = {
  "dbserver1" = {
    name = "test"
  }
}
