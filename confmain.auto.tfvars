# DEFINICION PRINCIPAL DE VARIABLES DE CONFIGURACION #
# USAR CON PRECAUCION #

### AUTENTICACION EN AZURE ###

client_id = "xxx"
# client_secret   = ""
tenant_id       = "xxx"
subscription_id = "xxx"

# "true" para habilitar entorno de prueba. "false" para deshabilitar entorno de prueba. Crea un RG adicional #

test = false

# INICIALES CLIENTE. 3 caracteres #
cliente = "XXX"

# Añadir Grupo de recursos. No modificar orden

resource_group_principal = ["Critical-Core", "Critical-App", "System-App"]

# "true" para crear las maquinas, "false" para no crearlas

create_linux_vms = false
create_win_vms   = false
create_database  = false
