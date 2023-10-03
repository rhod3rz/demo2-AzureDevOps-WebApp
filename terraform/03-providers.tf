#================================================================================================
# Provider Configuration
#================================================================================================

terraform {
  required_version = "~> 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = var.environment == "prd" ? true : false
    }
  }
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  subscription_id = var.subscription_id
  # client_secret = Use $env:ARM_CLIENT_SECRET or ARM_CLIENT_SECRET if bash
}

#================================================================================================
# Backend Configuration
#================================================================================================

terraform {
  backend "azurerm" {
    storage_account_name = "sadlterraformstate210713" # UPDATE HERE.
    container_name       = "demo20"                   # UPDATE HERE.
    # key                = Specify via t init -backend-config="key=env-feature.tfstate"
    # access_key         = Use $env:ARM_ACCESS_KEY or ARM_ACCESS_KEY if bash
  }
}
