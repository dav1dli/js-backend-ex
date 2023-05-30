variable "location" {
  type = string
  description = "Azure Region where resources will be provisioned"
  default = "northeurope"
}
variable "environment" {
  type = string
  description = "Environment"
  default = ""
}

variable "project" {
  type = string
  description = "Application project"
  default = ""
}

variable "region" {
  type = string
  description = "Environment region"
  default = "EUR-WW"
}
variable "tags" {
  description = "Specifies tags for all the resources"
  default     = {
    createdWith = "Terraform"
  }
}
variable "log_analytics_workspace_name" {
  description = "Specifies the name of the log analytics workspace"
  default     = ""
  type        = string
}
variable "log_analytics_retention_days" {
  description = "Specifies the number of days of the retention policy"
  type        = number
  default     = 30
}


variable "vnet_address_space" {
  description = "Specifies the address prefix of the AKS subnet"
  default     =  ["10.0.0.0/16"]
  type        = list(string)
}
variable "cap_subnet_name" {
  description = "Specifies the name of the subnet that hosts container apps"
  default     =  "PodsSubnet"
  type        = string
}

variable "cap_subnet_address_prefix" {
  description = "Specifies the address prefix of the subnet that hosts container apps"
  default     =  ["10.0.0.0/22"]
  type        = list(string)
}
variable "priv_endpt_subnet_name" {
  description = "Specifies the name of the subnet that hosts private endpoints"
  default     =  "PrivateEndpointsSubnet"
  type        = string
}
variable "priv_endpt_subnet_address_prefix" {
  description = "Specifies the address prefix of the subnet that hosts private endpoints"
  default     =  ["10.0.4.0/24"]
  type        = list(string)
}
variable "bstn_subnet_name" {
  description = "Specifies the name of the subnet that hosts the nodes"
  default     =  "BastionSubnet"
  type        = string
}

variable "bstn_subnet_address_prefix" {
  description = "Specifies the address prefix of the subnet that hosts nodes"
  default     =  ["10.0.5.128/27"]
  type        = list(string)
}
variable "mng_subnet_name" {
  description = "Specifies the name of the subnet that hosts management resources"
  default     =  "ManagementSubnet"
  type        = string
}

variable "mng_subnet_address_prefix" {
  description = "Specifies the address prefix of the subnet that hosts management resources"
  default     =  ["10.0.5.0/25"]
  type        = list(string)
}
# ACR ---------------------------------------------------------------
variable "acr_name" {
  description = "Specifies the name of the container registry"
  type        = string
  default     = ""
}

variable "acr_sku" {
  description = "Specifies the name of the container registry"
  type        = string
  default     = "Premium"

  validation {
    condition = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "The container registry sku is invalid."
  }
}

variable "acr_admin_enabled" {
  description = "Specifies whether admin is enabled for the container registry"
  type        = bool
  default     = true
}
  # Storage account ---------------------------------------------------------------
variable "storage_account_kind" {
  description = "(Optional) Specifies the account kind of the storage account"
  default     = "StorageV2"
  type        = string

   validation {
    condition = contains(["Storage", "StorageV2"], var.storage_account_kind)
    error_message = "The account kind of the storage account is invalid."
  }
}
variable "storage_account_tier" {
  description = "(Optional) Specifies the account tier of the storage account"
  default     = "Standard"
  type        = string

   validation {
    condition = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "The account tier of the storage account is invalid."
  }
}
variable "storage_account_replication_type" {
  description = "(Optional) Specifies the replication type of the storage account"
  default     = "LRS"
  type        = string

  validation {
    condition = contains(["LRS", "ZRS", "GRS", "GZRS", "RA-GRS", "RA-GZRS"], var.storage_account_replication_type)
    error_message = "The replication type of the storage account is invalid."
  }
}
# Jump host ---------------------------------------------------------------
variable "jump_host_name" {
  description = "Specifies the name of the jump host (bastion)"
  type        = string
  default     = ""
}
variable "vm_public_ip" {
  description = "(Optional) Specifies whether create a public IP for the virtual machine"
  type = bool
  default = true
}

variable "vm_size" {
  description = "Specifies the size of the jumpbox virtual machine"
  default     = "Standard_B2s"
  type        = string
}

variable "vm_os_disk_storage_account_type" {
  description = "Specifies the storage account type of the os disk of the jumpbox virtual machine"
  default     = "Standard_LRS"
  type        = string

  validation {
    condition = contains(["Premium_LRS", "Premium_ZRS", "StandardSSD_LRS", "StandardSSD_ZRS",  "Standard_LRS"], var.vm_os_disk_storage_account_type)
    error_message = "The storage account type of the OS disk is invalid."
  }
}

variable "vm_os_disk_image" {
  type        = map(string)
  description = "Specifies the os disk image of the virtual machine"
  default     = {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}
variable "vm_shutdown_time" {
  description = "Specifies the time when the VM auto-shuts down"
  default     = "2000"
  type        = string
}

variable "domain_name_label" {
  description = "Specifies the domain name for the jumbox virtual machine"
  default     = ""
  type        = string
}
variable "bastion_name" {
  description = "(Optional) Specifies the name of the bastion host"
  default     = ""
  type        = string
}
variable "admin_username" {
  description = "(Required) Specifies the admin username of the jumpbox virtual machine and AKS worker nodes."
  type        = string
  default     = "azureuser"
}
variable "ssh_public_key" {
  description = "(Required) Specifies the SSH public key for the jumpbox virtual machine and AKS worker nodes."
  type        = string
  default     = "~/.ssh/aks-tf-ssh-key.pub"
}