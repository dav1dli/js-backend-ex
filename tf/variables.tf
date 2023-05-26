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
  description = "Specifies the name of the subnet that hosts the nodes"
  default     =  "PrivateEndpointsSubnet"
  type        = string
}
variable "priv_endpt_subnet_address_prefix" {
  description = "Specifies the address prefix of the subnet that hosts nodes"
  default     =  ["10.0.4.0/24"]
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