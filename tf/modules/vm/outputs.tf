output "public_ip" {
  description = "Specifies the public IP address of the virtual machine"
  value       = azurerm_linux_virtual_machine.virtual_machine.public_ip_address
}
output "username" {
  description = "Specifies the username of the virtual machine"
  value       = var.vm_user
}
output "vm_managed_id" {
  description = "Specifies the identity id of the virtual machine"
  value       = azurerm_linux_virtual_machine.virtual_machine.identity[0].principal_id
}