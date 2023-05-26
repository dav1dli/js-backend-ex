output "env" {
  value = var.environment
}
output "location" {
  value = azurerm_resource_group.rg.location
}
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}
output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "application_object_id" {
  value = data.azuread_application.app_registration.id
}