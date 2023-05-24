data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "rg" {
    name     = local.resource_group
    location = var.location
    tags     = var.tags
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
          name : local.bstn_subnet
          address_prefixes : var.bstn_subnet_address_prefix
        },
        {
          name : local.mng_subnet
          address_prefixes : var.mng_subnet_address_prefix
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
}