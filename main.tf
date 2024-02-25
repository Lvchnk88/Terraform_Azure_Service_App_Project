
# Create a resource group
resource "azurerm_resource_group" "rg-app" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

# Create ACR
resource "azurerm_container_registry" "acr" {
  name                = "SergiiACR"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  sku                 = "Basic"
  admin_enabled       = false

    provisioner "local-exec" {
    command = "echo >> push_an_image.sh"
  }
}

# # Create Key Vault Secret
# data "azurerm_client_config" "current" {}

# # Set Vault
# resource "azurerm_key_vault" "vault" {
#   name                       = "sergii-vault"
#   location                   = var.resource_group_location
#   resource_group_name        = var.resource_group_name
#   tenant_id                  = data.azurerm_client_config.current.tenant_id
#   sku_name                   = "standard"
#   soft_delete_retention_days = 7

#   access_policy {
#     tenant_id = data.azurerm_client_config.current.tenant_id
#     object_id = data.azurerm_client_config.current.object_id

#     key_permissions = [
#       "Create",
#       "Delete",
#       "Get",
#       "List",
#       "Purge",
#       "Recover",
#       "Update",
#       "GetRotationPolicy",
#       "SetRotationPolicy"
#     ]

#     secret_permissions = [
#       "Set", 
#       "Get",
#       "List",
#       "Set",
#       "Delete",
#       "Recover",
#       "Backup",
#       "Restore"
#     ]
#   }
# }

# # Create a key.
# resource "azurerm_key_vault_key" "key" {
#   name         = "sergii-Key"
#   key_vault_id = azurerm_key_vault.vault.id
#   key_type     = "RSA"
#   key_size     = 4096

#   key_opts = [
#     "decrypt",
#     "encrypt",
#     "sign",
#     "verify",
#     "unwrapKey",
#     "wrapKey"
#   ]

#   rotation_policy {
#     automatic {
#       time_before_expiry = "P30D"
#     }

#     expire_after         = "P90D"
#     notify_before_expiry = "P29D"
#   }
# }

# # Set Secret
# resource "azurerm_key_vault_secret" "secret" {
#   name         = "test-secret"
#   value        = "ivan_vtoma"
#   key_vault_id = azurerm_key_vault.vault.id
# }

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "sergii-network"
  address_space       = ["10.0.0.0/16"]
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "sergii-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "sergii-delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# Create the Linux App Service Plan
resource "azurerm_service_plan" "appserviceplan" {
  name                = "webapp-serviceplan"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = "B1"
}

# Create the web app, pass in the App Service Plan ID
resource "azurerm_linux_web_app" "webapp1" {
  name                  = "Levchenko-1"
  location              = var.resource_group_location
  resource_group_name   = var.resource_group_name
  service_plan_id       = azurerm_service_plan.appserviceplan.id
  https_only            = true
  site_config { 
    minimum_tls_version = "1.2"
  }
}

# Create the web app, pass in the App Service Plan ID
resource "azurerm_linux_web_app" "webapp2" {
  name                  = "Levchenko-2"
  location              = var.resource_group_location
  resource_group_name   = var.resource_group_name
  service_plan_id       = azurerm_service_plan.appserviceplan.id
  https_only            = true
  site_config { 
    minimum_tls_version = "1.2"
  }
}

# Swift connection1
resource "azurerm_app_service_virtual_network_swift_connection" "swift1" {
  app_service_id = azurerm_linux_web_app.webapp1.id
  subnet_id      = azurerm_subnet.subnet.id
}

# Swift connection2
resource "azurerm_app_service_virtual_network_swift_connection" "swift2" {
  app_service_id = azurerm_linux_web_app.webapp2.id
  subnet_id      = azurerm_subnet.subnet.id
}

