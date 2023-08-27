terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
    random = {
      source  = "hashicorp/random"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~>1.8.0"
    }
  }

  required_version = ">= 1.0.0"
}

provider "azapi" {
}

provider "azurerm" {
  features {}

  skip_provider_registration = true
}

#####################################
# Fetch the GitHub token from Azure Key Vault
# Dev Center Project identity needs Azure Key Vault Secrets User role
#####################################
data "azurerm_key_vault_secret" "github_token" {
  name         = "github-token"
  key_vault_id = var.key_vault_id
}

data "github_repository" "k8s_state" {
  full_name = var.k8s_state_repo
}

provider "github" {
  token = data.azurerm_key_vault_secret.github_token.value
}
