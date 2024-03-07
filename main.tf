# Azure naming
module "naming" {
  source = "Azure/naming/azurerm"
  suffix = ["lvchnk88"]
}

# Create a RESOURCE CROUP
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
    command     = "./push_an_image.sh '${local.server}' '${local.username}' '${local.password}'"
    interpreter = ["bash", "-c"]
  }
}

# Create VIRTUAL NETWORK
resource "azurerm_virtual_network" "vnet" {
  name                = module.naming.virtual_network.name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg_app.location
  resource_group_name = azurerm_resource_group.rg_app.name
}

# Create SUBNET
resource "azurerm_subnet" "web_app_subnet" {
  name                 = module.naming.subnet.name
  resource_group_name  = azurerm_resource_group.rg_app.name
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

# Create the Linux APP SERVICE PLAN
resource "azurerm_service_plan" "app_service_plan" {
  name                = module.naming.app_service_plan.name
  location            = azurerm_resource_group.rg_app.location
  resource_group_name = azurerm_resource_group.rg_app.name
  os_type             = "Linux"
  sku_name            = "B1"
}

# Create Azure LINUX WEB
resource "azurerm_linux_web_app" "app_service" {
  # count = 2
  for_each = toset(var.app_service_name)

  name                      = "${each.value}-appsvc"
  location                  = azurerm_resource_group.rg_app.location
  resource_group_name       = azurerm_resource_group.rg_app.name
  service_plan_id           = azurerm_service_plan.app_service_plan.id
  virtual_network_subnet_id = azurerm_subnet.web_app_subnet.id
  public_network_access_enabled = true
  app_settings = {
    WEBSITED_PORT = 80
    DOCKER_ENABLE_CI = true
    WEBSITES_CONTAINER_START_TIME_LIMIT = 400
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
    DOCKER_REGISTRY_SERVER_URL = "https://${azurerm_container_registry.acr.login_server}"
  }

  # Configure Docker Image to load on start
  site_config {
    container_registry_use_managed_identity       = true
    application_stack {
      docker_image_name   = "samples/httpd:latest"
      docker_registry_url = "https://${azurerm_container_registry.acr.login_server}"
    }
  }
  identity {
    type = "SystemAssigned"
  }
  logs {
    application_logs {
      file_system_level = "Information"
    }
  }
}