# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# The following set of variables can be moved to a separate file <name>.tfvars
# https://www.terraform.io/docs/language/values/variables.html#variable-definitions-tfvars-files
# terraform apply -var-file="testing.tfvars" or
# terraform apply -var="name=<your_name>" -var="region=northeurope"
variable "name" {
  type = string
  default = "SRERolewebapp"
  description = "The name of which your resources should start with."
  validation {
    condition = can(regex("^[0-9A-Za-z]+$", var.name))
    error_message = "Only a-z, A-Z and 0-9 are allowed to match Azure storage naming restrictions."
  }
}

variable "region" {
  type = string
  default = "West Europe"
  description = "The Azure Region where the Resource Group should exist."
}

variable "owner" {
  type = string
  default = "GrandStrad"
  description = "Used in created by tags to identify the owner of the resources."
}

variable "environment" {
  type = string
  default = "UAT"
  description = "Sets the environment for the resources"
}
### End of variables

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    "CreatedBy"   = var.owner
    "Environment" = var.environment
  }
}

resource "random_id" "server" {
  keepers = {
    # Generate a new id each time we switch to a new Azure Resource Group
    rg_id = var.name
  }

  byte_length = 4
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.name}-rg-${random_id.server.hex}"
  location = var.region
}

# Create storage account
resource "azurerm_storage_account" "storage" {
  name                     = "${var.name}${random_id.server.hex}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.common_tags
}

## Create storage account container
resource "azurerm_storage_container" "storage_container" {
  name                  = "my-container"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}


# Create app service plan
resource "azurerm_app_service_plan" "plan" {
  name                = "${var.name}-plan-${random_id.server.hex}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "Windows"

  sku {
    tier = "Basic"
    size = "B1"
  }

  tags = local.common_tags
}

# Create application insights
resource "azurerm_application_insights" "appinsights" {
  name                = "${var.name}-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"

  tags = local.common_tags
}

# Create app service
resource "azurerm_app_service" "webapp" {
  name                = "${var.name}-${var.environment}-${random_id.server.hex}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.plan.id

  tags = local.common_tags

  site_config {
    always_on                = true
    dotnet_framework_version = "v5.0"
    app_command_line         = "dotnet EventManagement.Web.dll"
  }

  app_settings = {
    "EVENT_CONTAINER"                     = azurerm_storage_container.storage_container.name
    "RANDOM_KEY"                          = "random_value"
    "NESTED__VARIABLE"                    = "<variable>"
    "WEBSITE_RUN_FROM_PACKAGE"            = 1
    "APPINSIGHTS_INSTRUMENTATIONKEY"      = azurerm_application_insights.appinsights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.appinsights.connection_string
  }

  connection_string {
    name  = "StorageAccount"
    type  = "Custom"
    value = azurerm_storage_account.storage.primary_connection_string
  }
}