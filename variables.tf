variable "resource_group_location" {
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  type        = string
  default     = "rg-app-terraform"
}

variable "app_service_name" {
  type        = list(string)
  default     = ["lvchnk88-1", "lvchnk88-2"]  
}

variable "azurerm_virtual_network_name" {
  type        = string
  default     = "sergii-network"  
}

variable "azurerm_subnet_name" {
  type        = string
  default     = "sergii-subnet"  
}

variable "azurerm_app_service_plan_name" {
  type        = string
  default     = "app-plan"
}