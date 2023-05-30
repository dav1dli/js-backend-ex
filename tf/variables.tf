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
# Log analytics --------------------------------------------------------------
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

# Virtual network ----------------------------------------------------------------
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
# Key vault ---------------------------------------------------------------
variable "key_vault_sku_name" {
  description = "(Required) The Name of the SKU used for this Key Vault. Possible values are standard and premium."
  type        = string
  default     = "standard"
  validation {
    condition = contains(["standard", "premium" ], var.key_vault_sku_name)
    error_message = "The sku name of the key vault is invalid."
  }
}
variable "key_vault_enabled_for_deployment" {
  description = "(Optional) Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault. Defaults to false."
  type        = bool
  default     = false
}
variable "key_vault_enabled_for_disk_encryption" {
  description = " (Optional) Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys. Defaults to false."
  type        = bool
  default     = true
}
variable "key_vault_enabled_for_template_deployment" {
  description = "(Optional) Boolean flag to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault. Defaults to false."
  type        = bool
  default     = true
}
variable "key_vault_enable_rbac_authorization" {
  description = "(Optional) Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions. Defaults to false."
  type        = bool
  default     = false
}
variable "key_vault_purge_protection_enabled" {
  description = "(Optional) Is Purge Protection enabled for this Key Vault? Defaults to false."
  type        = bool
  default     = true
}
variable "key_vault_soft_delete_retention_days" {
  description = "(Optional) The number of days that items should be retained for once soft-deleted. This value can be between 7 and 90 (the default) days."
  type        = number
  default     = 30
}
variable "key_vault_bypass" {
  description = "(Required) Specifies which traffic can bypass the network rules. Possible values are AzureServices and None."
  type        = string
  default     = "AzureServices"
  validation {
    condition = contains(["AzureServices", "None" ], var.key_vault_bypass)
    error_message = "The valut of the bypass property of the key vault is invalid."
  }
}
variable "key_vault_default_action" {
  description = "(Required) The Default Action to use when no rules match from ip_rules / virtual_network_subnet_ids. Possible values are Allow and Deny."
  type        = string
  default     = "Allow"
  validation {
    condition = contains(["Allow", "Deny" ], var.key_vault_default_action)
    error_message = "The value of the default action property of the key vault is invalid."
  }
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
# Container app -----------------------------------------------------------
variable "cap_private" {
  description = "(Optional) Boolean flag to specify whether the Container App Environment is private. Defaults to false."
  type        = bool
  default     = false
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