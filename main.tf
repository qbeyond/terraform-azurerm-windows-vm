resource "azurerm_public_ip" "this" {
  count               = local.public_ip.enabled ? 1 : 0
  name                = local.public_ip.name
  resource_group_name = var.resource_group.name
  location            = local.public_ip.location
  allocation_method   = local.public_ip.allocation_method

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_network_interface" "this" {
  name                = local.nic.name
  location            = local.nic.location
  resource_group_name = var.resource_group.name
  dns_servers         = local.nic.dns_servers

  ip_configuration {
    name                          = local.nic.ip_config_name
    subnet_id                     = local.nic.subnet_id
    private_ip_address_allocation = local.nic.ip_address_allocation
    private_ip_address            = local.nic.ip_address
    public_ip_address_id          = local.public_ip.enabled ? azurerm_public_ip.this[0].id : null
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_network_interface_security_group_association" "this" {
  count = local.nic.nsg_id == null ? 0 : 1
  network_interface_id = azurerm_network_interface.this.id
  network_security_group_id = local.nic.nsg_id
}

resource "azurerm_windows_virtual_machine" "this" {
  name                     = local.virtual_machine.name
  computer_name            = local.virtual_machine.computer_name
  location                 = local.virtual_machine.location
  resource_group_name      = var.resource_group.name
  size                     = local.virtual_machine.size
  provision_vm_agent = true
  admin_username           = local.virtual_machine.admin_username
  admin_password           = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]

  os_disk {
    caching              = local.virtual_machine.caching
    storage_account_type = local.virtual_machine.storage_account_type
    disk_size_gb         = local.virtual_machine.disk_size_gb
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = local.virtual_machine.sku
    version   = local.virtual_machine.version
  }

  availability_set_id = local.virtual_machine.availability_set_id
  zone                = local.virtual_machine.zone
  tags                = local.virtual_machine.tags

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      identity,
      tags
    ]
  }
}