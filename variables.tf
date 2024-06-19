variable "resource_group_location" {
  type        = string
  default     = "eastus"
  description = "Local do grupo de recursos"
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "rg"
  description = "Prefixo para o grupo de recursos que vai ser combinado com um nome randomico."
}

variable "username" {
  type        = string
  description = "O usuario que vai ser usado pra acessar a VM."
  default     = "azureadmin"
}

variable "vm_count" {
  description = "Number of VMs"
  type        = number
  default     = 2
}

variable "vm_network_interface_name_prefix" {
  type        = string
  description = "Nome das interface de rede das VMs"
  default     = "myNicVM"
}

variable "vm_name_prefix" {
  type        = string
  description = "Nome das VMs"
  default     = "myVM"
}

variable "azure_client_id" {
  type        = string
  description = "Azure Client Id"
}

variable "azure_client_secret" {
  type        = string
  description = "Azure Client Secret"
}

variable "azure_subscription_id" {
  type        = string
  description = "Azure Subscription Id"
}

variable "azure_tenant_id" {
  type        = string
  description = "Azure Tenant Id"
}

