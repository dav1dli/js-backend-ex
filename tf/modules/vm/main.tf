terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

resource "azurerm_public_ip" "public_ip" {
  name                = "${var.name}-PublicIp"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
  domain_name_label   = lower(var.domain_name_label)
  count               = var.public_ip ? 1 : 0
  tags                = var.tags

  lifecycle {
    ignore_changes = [
        tags
    ]
  }
}
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.name}-Nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  lifecycle {
    ignore_changes = [
        tags
    ]
  }
}
resource "azurerm_network_interface" "nic" {
  name                = "${var.name}-Nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "Configuration"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = try(azurerm_public_ip.public_ip[0].id, "")
  }
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
resource "azurerm_network_interface_security_group_association" "nsg_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
  depends_on = [azurerm_network_security_group.nsg]
}



resource "azurerm_linux_virtual_machine" "virtual_machine" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  network_interface_ids         = [azurerm_network_interface.nic.id]
  size                          = var.size
  computer_name                 = var.name
  admin_username                = var.vm_user
  custom_data                   = var.custom_data
  tags                          = var.tags

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                 = "${var.name}-OsDisk"
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_storage_account_type
  }

  admin_ssh_key {
    username   = var.vm_user
    public_key = var.admin_ssh_public_key
  }

  source_image_reference {
    offer     = lookup(var.os_disk_image, "offer", null)
    publisher = lookup(var.os_disk_image, "publisher", null)
    sku       = lookup(var.os_disk_image, "sku", null)
    version   = lookup(var.os_disk_image, "version", null)
  }
  boot_diagnostics {
    storage_account_uri = var.boot_diagnostics_storage_account == "" ? null : var.boot_diagnostics_storage_account
  }
  lifecycle {
    ignore_changes = [
        tags
    ]
  }
  # This won't work from office network when running locally on Mac because ssh is disabled from GAW network
  # Use VPN
  # connection {
  #   type        = "ssh"
  #   user        = var.vm_user
  #   private_key = "${file(var.admin_ssh_private_key)}"
  #   host        = azurerm_linux_virtual_machine.virtual_machine.public_ip_address
  # }
  # provisioner "remote-exec" {
  #   inline = [
  #     "mkdir /home/${var.vm_user}/.kube"
  #   ]
  # }
  # provisioner "file" {
  #   source      = var.kubeconfig
  #   destination = "/home/${var.vm_user}/.kube/config"

  # }

  depends_on = [
    azurerm_network_interface.nic,
    azurerm_network_security_group.nsg
  ]
}

resource "azurerm_monitor_diagnostic_setting" "nsg_settings" {
  name                       = "DiagnosticsSettings"
  target_resource_id         = azurerm_network_security_group.nsg.id
  log_analytics_workspace_id = var.log_analytics_workspace_resource_id

  enabled_log {
    category = "NetworkSecurityGroupEvent"

    retention_policy {
      enabled = true
      days    = var.log_analytics_retention_days
    }
  }

 enabled_log {
    category = "NetworkSecurityGroupRuleCounter"

    retention_policy {
      enabled = true
      days    = var.log_analytics_retention_days
    }
  }
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "autoshutdown" {
  virtual_machine_id = azurerm_linux_virtual_machine.virtual_machine.id
  location           = var.location
  enabled            = true

  daily_recurrence_time = var.shutdown_time
  timezone              = var.shutdown_timezone

  notification_settings {
    enabled         = false
  }
}