output "name" {
  depends_on = [azurerm_bastion_host.bastion_host]
  value = azurerm_bastion_host.bastion_host.*.name
  description = "Specifies the name of the bastion host"
}

output "id" {
  depends_on = [azurerm_bastion_host.bastion_host]
  value = azurerm_bastion_host.bastion_host.*.id
  description = "Specifies the resource id of the bastion host"
}