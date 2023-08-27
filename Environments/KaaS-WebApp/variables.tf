variable "k8s_state_repo" {
  type        = string
  default     = "lopezleandro03/k8s-state"
  description = "The name of the GitHub repository to store the Terraform state file in."
}

variable "key_vault_id" {
  type        = string
  description = "The ID of the Azure Key Vault to store the GitHub token in."
  default     = "/subscriptions/4ad9490b-017e-4a82-8892-39c294f3af9c/resourceGroups/rg-azd-devcenter/providers/Microsoft.KeyVault/vaults/akv-ntawodiyy2yzy"
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
