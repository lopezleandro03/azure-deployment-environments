##############################
# random_string for k8s resources uniqueness
##############################
resource "random_string" "value" {
  length  = 3
  upper = false
}

##############################
# fetch resource group
##############################
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}


locals {
  k8s_app_name = "${var.app_name}-${random_string.value.result}"
  k8s_app_host = "ade-kaas-demo.westeurope.cloudapp.azure.com"
  k8s_name = "aks-kaas"
  k8s_state_branch = "main"
  k8s_state_cluster_root = "clusters/${local.k8s_name}"
  k8s_state_cluster_apps = "apps"
  k8s_templates = "k8s-templates"
  workbook_name = uuid()
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
    app_name = local.k8s_app_name,
    app_host = local.k8s_app_host
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
    app_name = local.k8s_app_name,
    app_host = local.k8s_app_host
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

##############################
# Output in azure workbook
##############################
resource "azapi_resource" "workbook" {
  type = "Microsoft.Insights/workbooks@2022-04-01"
  name = local.workbook_name
  location = data.azurerm_resource_group.rg.location
  parent_id = data.azurerm_resource_group.rg.id
  body = jsonencode({
    properties = {
      category = "Info"
      description = "Application metadata"
      displayName = "Application metadata"
      sourceId = data.azurerm_resource_group.rg.id
      serializedData = templatefile("workbook-template/workbook.json", 
        {
            app_url = "https://${local.k8s_app_host}/${local.k8s_app_name}",
            app_name = local.k8s_app_name,
        })
    }
    kind = "shared"
  })
}