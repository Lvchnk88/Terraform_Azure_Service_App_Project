# Azure naming
module "naming" {
  source  = "Azure/naming/azurerm"
  suffix = [ "lvchnk88" ]
}

# Create a resource group
resource "azurerm_resource_group" "rg_app" {
  name     = module.naming.resource_group.name
  location = var.resource_group_location
}

# Create ACR
resource "azurerm_container_registry" "acr" {
  name                = module.naming.container_registry.name
  resource_group_name = azurerm_resource_group.rg_app.name
  location            = azurerm_resource_group.rg_app.location
  sku                 = "Basic"
  admin_enabled       = true

  depends_on = [ 
    azurerm_resource_group.rg_app
   ]
}

# Docker PUSH image in to ACR
resource "null_resource" "docker_push" {
  provisioner "local-exec" {
    command = "./push_an_image.sh '${local.server}' '${local.username}' '${local.password}'"
    interpreter = ["bash", "-c"]
  }
}

# # Create virtual network
# resource "azurerm_virtual_network" "vnet" {
#   name                = module.naming.virtual_network.name
#   address_space       = ["10.0.0.0/16"]
#   location            = azurerm_resource_group.rg_app.location
#   resource_group_name = azurerm_resource_group.rg_app.name
# }

# # Create subnet
# resource "azurerm_subnet" "web_app_subnet" {
#   name                 = module.naming.subnet.name
#   resource_group_name  = azurerm_resource_group.rg_app.name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes     = ["10.0.1.0/24"]

#   delegation {
#     name = "sergii-delegation"

#     service_delegation {
#       name    = "Microsoft.Web/serverFarms"
#       actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
#     }
#   }
# }

# # Create the Linux App Service Plan
# resource "azurerm_service_plan" "app_service_plan" {
#   name                = module.naming.app_service_plan.name
#   location            = azurerm_resource_group.rg_app.location
#   resource_group_name = azurerm_resource_group.rg_app.name
#   os_type             = "Linux"
#   sku_name            = "B1"
# }

# # # Create Manages a User Assigned Identity
# # resource "azurerm_user_assigned_identity" "user" {
# #   location            = azurerm_resource_group.rg_app.location
# #   name                = "acruser"
# #   resource_group_name = azurerm_resource_group.rg_app.name
# # }

# # Create Azure Linux Web App
# resource "azurerm_linux_web_app" "app-service" {
#   # count = 2
#   for_each              = toset(var.app_service_name)

#   name                  = "${each.value}-appsvc"
#   location              = azurerm_resource_group.rg_app.location
#   resource_group_name   = azurerm_resource_group.rg_app.name
#   service_plan_id       = azurerm_service_plan.app_service_plan.id
#   virtual_network_subnet_id = azurerm_subnet.web_app_subnet.id
#   app_settings = {
#     docker_registry_url = "https://${azurerm_container_registry.acr.login_server}"
#   }

#   # Configure Docker Image to load on start
#   site_config {
#     always_on                                     = false
#     worker_count                                  = 1
#     #container_registry_use_managed_identity       = true
#     #container_registry_managed_identity_client_id = azurerm_user_assigned_identity.user.client_id
#     application_stack {
#       docker_image_name   = "samples/nginx:latest"
#       docker_registry_url = "https://${azurerm_container_registry.acr.login_server}"
#     }
#   }
#   identity {
#     type = "SystemAssigned"
#   }
# }

# # # data "azurerm_container_registry" "this" {
# # #   name                = azurerm_container_registry.acr.name
# # #   resource_group_name = azurerm_resource_group.rg_app.name
# # # }

# # # resource "azurerm_role_assignment" "role-acr" {
# # #   for_each             = azurerm_service.app-service.id
  
# # #   role_definition_name = "AcrPull"
# # #   scope                = azurerm_container_registry.this.id
# # #   principal_id         = each.value.identity[0].principal_id
# # # }