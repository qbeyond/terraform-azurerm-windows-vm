resource "azurerm_public_ip" "this" {
  count               = var.public_ip_config.enabled ? 1 : 0
  name                = local.public_ip.name
  resource_group_name = var.resource_group_name
  location            = var.virtual_machine_config.location
  allocation_method   = var.public_ip_config.allocation_method

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_network_interface" "this" {
  name                = local.nic.name
  location            = var.virtual_machine_config.location
  resource_group_name = var.resource_group_name
  dns_servers         = var.nic_config.dns_servers

  ip_configuration {
    name                          = local.nic.ip_config_name
    subnet_id                     = var.subnet.id
    private_ip_address_allocation = var.nic_config.private_ip == null ? "Dynamic" : "Static"
    private_ip_address            = var.nic_config.private_ip
    public_ip_address_id          = var.public_ip_config.enabled ? azurerm_public_ip.this[0].id : null
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_network_interface_security_group_association" "this" {
  count = var.nic_config.nsg_id == null ? 0 : 1
  network_interface_id = azurerm_network_interface.this.id
  network_security_group_id = var.nic_config.nsg_id
}

resource "azurerm_windows_virtual_machine" "this" {
  name                     = local.virtual_machine.name
  computer_name            = var.virtual_machine_config.hostname
  location                 = var.virtual_machine_config.location
  resource_group_name      = var.resource_group_name
  size                     = var.virtual_machine_config.size
  provision_vm_agent = true
  admin_username           = var.virtual_machine_config.admin_username
  admin_password           = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]

  os_disk {
    caching              = var.virtual_machine_config.os_disk_caching
    storage_account_type = var.virtual_machine_config.os_disk_storage_type
    disk_size_gb         = var.virtual_machine_config.os_disk_size_gb
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = var.virtual_machine_config.os_sku
    version   = var.virtual_machine_config.os_version
  }

  availability_set_id = var.virtual_machine_config.availability_set_id
  zone                = var.virtual_machine_config.zone
  tags                = var.virtual_machine_config.tags

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      identity,
      tags
    ]
  }
}