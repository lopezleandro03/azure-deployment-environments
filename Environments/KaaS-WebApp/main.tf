terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
    azurerm = {
      version = "= 3.53.0"
    }
  }

  required_version = ">= 1.0.0"
}

provider "azurerm" {
  features {}

  skip_provider_registration = true
}

# configure the GitHub provider to use the token stored in the Key Vault
provider "github" {
  token = data.azurerm_key_vault_secret.github_token.value
}

# fetch the GitHub token from the Key Vault
data "azurerm_key_vault_secret" "github_token" {
  name         = "github-token"
  key_vault_id = var.key_vault_id
}

# fetch the GitHub repository
data "github_repository" "k8s_state" {
  full_name = var.k8s_state_repo
}

# create a file in the GitHub repository
resource "github_repository_file" "test_file" {
  repository          = data.github_repository.k8s_state.name
  branch              = "main"
  file                = "test"
  content             = "this is a test"
  commit_message      = "Managed by Terraform"
  commit_author       = "Azure Deployment Environments Processor"
  commit_email        = "ade@microsoft.com"
}







# data "azurerm_resource_group" "rg" {
#   name = var.resource_group_name
# }
