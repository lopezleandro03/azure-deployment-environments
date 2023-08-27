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

# create random app name of 4 characters long
resource "random_string" "value" {
  length  = 4
  lower = true
  special = false
}

# fetch the GitHub repository
data "github_repository" "k8s_state" {
  full_name = var.k8s_state_repo
}

locals {
  k8s_app_name = "${var.app_name}-${random_string.value.result}"
  k8s_name = "aks-kaas"
  k8s_state_branch = "main"
  k8s_state_cluster_root = "clusters/${local.k8s_name}"
  k8s_state_cluster_apps = "apps"
  k8s_templates = "k8s-templates"
}

##############################
# Flux App kustomization
##############################
resource "github_repository_file" "flux_app_kustomization" {
  repository          = data.github_repository.k8s_state.name
  branch              = local.k8s_state_branch
  file                = "${local.k8s_state_cluster_apps}/${local.k8s_app_name}/kustomization.yml"
  content             = templatefile("${local.k8s_templates}/kustomization.yml", {
    app_name = local.k8s_app_name
  })
  commit_message      = "Managed by Terraform"
  commit_author       = "Azure Deployment Environments Processor"
  commit_email        = "ade@microsoft.com"
}

##############################
# K8s namespace
##############################
resource "github_repository_file" "k8s_namespace" {
  repository          = data.github_repository.k8s_state.name
  branch              = local.k8s_state_branch
  file                = "${local.k8s_state_cluster_apps}/${local.k8s_app_name}/namespace.yml"
  content             = templatefile("${local.k8s_templates}/namespace.yml", {
    app_name = local.k8s_app_name
  })
  commit_message      = "Managed by Terraform"
  commit_author       = "Azure Deployment Environments Processor"
  commit_email        = "ade@microsoft.com"
}

##############################
# K8s Persistent Volume Claim
##############################
resource "github_repository_file" "k8s_pvc" {
  repository          = data.github_repository.k8s_state.name
  branch              = local.k8s_state_branch
  file                = "${local.k8s_state_cluster_apps}/${local.k8s_app_name}/pvc.yml"
  content             = templatefile("${local.k8s_templates}/pvc.yml", {
    app_name = local.k8s_app_name
  })
  commit_message      = "Managed by Terraform"
  commit_author       = "Azure Deployment Environments Processor"
  commit_email        = "ade@microsoft.com"
}

##############################
# K8s Deployment
##############################
resource "github_repository_file" "k8s_deployment" {
  repository          = data.github_repository.k8s_state.name
  branch              = local.k8s_state_branch
  file                = "${local.k8s_state_cluster_apps}/${local.k8s_app_name}/deployment.yml"
  content             = templatefile("${local.k8s_templates}/deployment.yml", {
    app_name = local.k8s_app_name
  })
  commit_message      = "Managed by Terraform"
  commit_author       = "Azure Deployment Environments Processor"
  commit_email        = "ade@microsoft.com"
}

##############################
# K8s Service
##############################
resource "github_repository_file" "k8s_service" {
  repository          = data.github_repository.k8s_state.name
  branch              = local.k8s_state_branch
  file                = "${local.k8s_state_cluster_apps}/${local.k8s_app_name}/service.yml"
  content             = templatefile("${local.k8s_templates}/service.yml", {
    app_name = local.k8s_app_name
  })
  commit_message      = "Managed by Terraform"
  commit_author       = "Azure Deployment Environments Processor"
  commit_email        = "ade@microsoft.com"
}

##############################
# K8s Ingress
##############################
resource "github_repository_file" "k8s_ingress" {
  repository          = data.github_repository.k8s_state.name
  branch              = local.k8s_state_branch
  file                = "${local.k8s_state_cluster_apps}/${local.k8s_app_name}/ingress.yml"
  content             = templatefile("${local.k8s_templates}/ingress.yml", {
    app_name = local.k8s_app_name
  })
  commit_message      = "Managed by Terraform"
  commit_author       = "Azure Deployment Environments Processor"
  commit_email        = "ade@microsoft.com"
}

##############################
# Flux root kustomization
# Pushing this file will hook up Flux and kick off the deployment, therefore, we do it at the end.
##############################
resource "github_repository_file" "flux_kustomization" {
  repository          = data.github_repository.k8s_state.name
  branch              = local.k8s_state_branch
  file                = "${local.k8s_state_cluster_root}/${local.k8s_app_name}.yml"
  content             = templatefile("${local.k8s_templates}/flux-kustomization.yml", 
  {
    app_name = local.k8s_app_name
  })
  commit_message      = "Managed by Terraform"
  commit_author       = "Azure Deployment Environments Processor"
  commit_email        = "ade@microsoft.com"

  depends_on = [ 
    github_repository_file.flux_app_kustomization,
    github_repository_file.k8s_namespace,
    github_repository_file.k8s_pvc,
    github_repository_file.k8s_deployment,
    github_repository_file.k8s_service,
    github_repository_file.k8s_ingress
  ]
}
