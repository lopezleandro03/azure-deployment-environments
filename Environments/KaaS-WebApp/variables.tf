variable "k8s_state_repo" {
  type        = string
  default     = "lopezleandro03/k8s-state"
  description = "The name of the GitHub repository to store the Terraform state file in."
}

variable "key_vault_id" {
  type        = string
  description = "The ID of the Azure Key Vault to store the GitHub token in."
  default     = "/subscriptions/4ad9490b-017e-4a82-8892-39c294f3af9c/resourceGroups/rg-dev-center-ade/providers/Microsoft.KeyVault/vaults/akv-yzcyothmmzixn"
}

variable "app_name" {
  type        = string
  description = "The name of the application."
  default = "ghost3"
}

variable "resource_group_name" {
    type        = string
    description = "The name of the resource group to create the App Service Plan in."
    default     = "rg-azd-devcenter"
}

variable "container_image" {
    type        = string
    description = "The name of the container image to deploy."
    default     = "ghost:3.42.5-alpine"
}

variable "env_vars" {
    type        = map(string)
    description = "A map of environment variables to set on the container."
    default     = {}  
}