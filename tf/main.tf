data "azurerm_client_config" "current" {
}
data "azuread_application" "app_registration" {
  display_name = local.ad_app
}
resource "azurerm_resource_group" "rg" {
    name     = local.resource_group
    location = var.location
    tags     = var.tags
}
resource "azurerm_role_assignment" "curr_user_role" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}
data "azuread_service_principal" "ad_app_sp" {
  application_id = data.azuread_application.app_registration.application_id
}
resource "azurerm_role_assignment" "ad_app_role" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = data.azuread_service_principal.ad_app_sp.object_id
}
module "log_analytics_workspace" {
  source                           = "./modules/analytics"
  name                             = local.log_analytics_workspace_name
  location                         = azurerm_resource_group.rg.location
  resource_group_name              = azurerm_resource_group.rg.name
}

module "vnet" {
    source              = "./modules/virtual_network"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    vnet_name           = local.vnet_name
    address_space       = var.vnet_address_space

    subnets = [
        {
          name : local.cap_subnet
          address_prefixes : var.cap_subnet_address_prefix
        },
        {
          name : local.mng_subnet
          address_prefixes : var.mng_subnet_address_prefix
        },
        {
          name : local.bstn_subnet
          address_prefixes : var.bstn_subnet_address_prefix
        },
        {
          name : local.priv_endpt_subnet
          address_prefixes : var.priv_endpt_subnet_address_prefix
        },
  ]
}
# ACR container registry ---------------------------------------------------------------
module "acr" {
  source                       = "./modules/acr"
  name                         = local.acr_name
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  sku                          = var.acr_sku
  admin_enabled                = var.acr_admin_enabled
}
module "acr_private_dns_zone" {
  source                       = "./modules/private_dns_zone"
  name                         = "privatelink.azurecr.io"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_networks_to_link     = {
    (module.vnet.name) = {
      subscription_id = data.azurerm_client_config.current.subscription_id
      resource_group_name = azurerm_resource_group.rg.name
    }
  }
  depends_on                   = [ module.vnet ]
}
module "acr_private_endpoint" {
  source                         = "./modules/private_endpoint"
  name                           = local.acr_pep_name
  location                       = azurerm_resource_group.rg.location
  resource_group_name            = azurerm_resource_group.rg.name
  subnet_id                      = module.vnet.subnet_ids[local.priv_endpt_subnet]
  tags                           = var.tags
  private_connection_resource_id = module.acr.id
  is_manual_connection           = false
  subresource_name               = "registry"
  private_dns_zone_group_name    = "AcrPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.acr_private_dns_zone.id]
  depends_on                   = [ module.acr, module.vnet ]
}
# Key vault -----------------------------------------------------------------------------
module "key_vault" {
  source                          = "./modules/keyvault"
  name                            = local.kv_name
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = var.key_vault_sku_name
  tags                            = var.tags
  enabled_for_deployment          = var.key_vault_enabled_for_deployment
  enabled_for_disk_encryption     = var.key_vault_enabled_for_disk_encryption
  enabled_for_template_deployment = var.key_vault_enabled_for_template_deployment
  enable_rbac_authorization       = var.key_vault_enable_rbac_authorization
  purge_protection_enabled        = var.key_vault_purge_protection_enabled
  soft_delete_retention_days      = var.key_vault_soft_delete_retention_days
  bypass                          = var.key_vault_bypass
  default_action                  = var.key_vault_default_action
}
resource "azurerm_key_vault_access_policy" "opuser_kv_read" {
  key_vault_id       = module.key_vault.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = data.azurerm_client_config.current.object_id
  key_permissions    = [ "Get", "List", "Encrypt", "Decrypt", "Create", "Update" ]
  secret_permissions = [ "Get", "List", "Set" ]
}
resource "azurerm_key_vault_secret" "jump_host_ssh" {
  name         = local.jump_host_name
  value        = base64encode(file("~/.ssh/aks-tf-ssh-key"))
  key_vault_id = module.key_vault.id
}
module "kv_private_dns_zone" {
  source                       = "./modules/private_dns_zone"
  name                         = "privatelink.vaultcore.azure.net"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_networks_to_link     = {
    (module.vnet.name) = {
      subscription_id = data.azurerm_client_config.current.subscription_id
      resource_group_name = azurerm_resource_group.rg.name
    }
  }
}
module "kv_private_endpoint" {
  source                         = "./modules/private_endpoint"
  name                           = local.kv_pep_name
  location                       = azurerm_resource_group.rg.location
  resource_group_name            = azurerm_resource_group.rg.name
  subnet_id                      = module.vnet.subnet_ids[local.priv_endpt_subnet]
  tags                           = var.tags
  private_connection_resource_id = module.key_vault.id
  is_manual_connection           = false
  subresource_name               = "vault"
  private_dns_zone_group_name    = "KeyVaultPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.kv_private_dns_zone.id]
}
# Container app environment ------------------------------------------------------------
module "cap_environment" {
  source                         = "./modules/cap_env"
  name                           = local.cap_name
  resource_group_name            = azurerm_resource_group.rg.name
  location                       = azurerm_resource_group.rg.location
  log_analytics_workspace_id     = module.log_analytics_workspace.id
  infrastructure_subnet_id       = module.vnet.subnet_ids[local.cap_subnet]
  internal_load_balancer_enabled = var.cap_private
  depends_on                     = [ module.log_analytics_workspace, module.vnet ]
}
module "cap_private_dns_zone" {
  source                       = "./modules/private_dns_zone"
  name                         = module.cap_environment.default_domain
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_networks_to_link     = {
    (module.vnet.name) = {
      subscription_id = data.azurerm_client_config.current.subscription_id
      resource_group_name = azurerm_resource_group.rg.name
    }
  }
  depends_on                   = [ module.vnet ]
}
resource "azurerm_private_dns_a_record" "cap_static_ip" {
  name                = "*"
  zone_name           = module.cap_environment.default_domain
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [ module.cap_environment.static_ip_address ]
  depends_on          = [ module.cap_private_dns_zone, module.cap_environment ]
}
# Management VM -------------------------------------------------------------------------
resource "random_string" "storage_account_suffix" {
  length  = 4
  special = false
  lower   = true
  upper   = false
  numeric = false
}
module "storage_account" {
  source              = "./modules/storage_account"
  name                = lower("${local.storage_account_prefix}vmboot${random_string.storage_account_suffix.result}")
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  account_kind        = var.storage_account_kind
  account_tier        = var.storage_account_tier
  replication_type    = var.storage_account_replication_type
}
module "storage_account_private_dns_zone" {
  source                       = "./modules/private_dns_zone"
  name                         = "privatelink.blob.core.windows.net"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_networks_to_link     = {
    (module.vnet.name) = {
      subscription_id = data.azurerm_client_config.current.subscription_id
      resource_group_name = azurerm_resource_group.rg.name
    }
  }
}
module "blob_private_endpoint" {
  source                         = "./modules/private_endpoint"
  name                           = local.storage_account_pep_name
  location                       = azurerm_resource_group.rg.location
  resource_group_name            = azurerm_resource_group.rg.name
  subnet_id                      = module.vnet.subnet_ids[local.priv_endpt_subnet]
  tags                           = var.tags
  private_connection_resource_id = module.storage_account.id
  is_manual_connection           = false
  subresource_name               = "blob"
  private_dns_zone_group_name    = "BlobPrivateDnsZoneGroup"
  private_dns_zone_group_ids     = [module.storage_account_private_dns_zone.id]
}
module "jumphost" {
  source                              = "./modules/vm"
  name                                = local.jump_host_name
  resource_group_name                 = azurerm_resource_group.rg.name
  location                            = azurerm_resource_group.rg.location
  public_ip                           = var.vm_public_ip
  vm_user                             = var.admin_username
  admin_ssh_public_key                = file("files/aks-tf-ssh-key.pub")
  size                                = var.vm_size
  os_disk_image                       = var.vm_os_disk_image
  domain_name_label                   = lower(local.jump_host_name)
  subnet_id                           = module.vnet.subnet_ids[local.mng_subnet]
  boot_diagnostics_storage_account    = module.storage_account.primary_blob_endpoint
  log_analytics_workspace_id          = module.log_analytics_workspace.workspace_id
  log_analytics_workspace_key         = module.log_analytics_workspace.primary_shared_key
  log_analytics_workspace_resource_id = module.log_analytics_workspace.id
  log_analytics_retention_days        = var.log_analytics_retention_days
  custom_data                         = filebase64("files/mng-vm-init.sh")
  shutdown_time                       = var.vm_shutdown_time
  depends_on                          = [module.vnet, module.acr]
}
# resource "azurerm_role_assignment" "jumphost_acr_pull" {
#   principal_id                     = module.jumphost.vm_managed_id
#   role_definition_name             = "AcrPull"
#   scope                            = module.acr.id
#   skip_service_principal_aad_check = true
# }
resource "azurerm_role_assignment" "jumphost_contributor" {
  principal_id                     = module.jumphost.vm_managed_id
  role_definition_name             = "Contributor"
  scope                            = azurerm_resource_group.rg.id
  skip_service_principal_aad_check = true
}
resource "azurerm_key_vault_access_policy" "jumphost_kv_key_read" {
  key_vault_id    = module.key_vault.id
  tenant_id       = data.azurerm_client_config.current.tenant_id
  object_id       = module.jumphost.vm_managed_id
  key_permissions = [ "Get", "List", "Encrypt", "Decrypt" ]
}
module "bastion" {
  source                       = "./modules/bastion"
  name                         = local.bastion_name
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  subnet_id                    = module.vnet.subnet_ids[local.bstn_subnet]
  depends_on                   = [module.vnet]
}