terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create an Azure Resource Group to house our bootcamp project
resource "azurerm_resource_group" "rg" {
  name     = "rg-cloud-bootcamp-project"
  location = "East US"
}
# 1. Create a Log Analytics Workspace (Required for monitoring Container Apps)
resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-bootcamp-logs"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
}

# 2. Create the Container App Environment (The secure baseline cluster)
resource "azurerm_container_app_environment" "env" {
  name                       = "cae-bootcamp-env"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
}

# 3. Create the Live Container App pointing to your GitHub Package image
resource "azurerm_container_app" "app" {
  name                         = "portfolio-web-app"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "web-container"
      image  = "ghcr.io/fatufofana52-stack/cloud-portfolio-app:latest"
      cpu    = "0.25"
      memory = "0.5Gi"
    }
  }

  ingress {
    allow_insecure_connections = false
    target_port                = 8080
    external_enabled           = true
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}
