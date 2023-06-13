resource "azurerm_public_ip" "this" {
  count               = local.pip.enabled ? 1 : 0
  name                = local.pip.name
  resource_group_name = var.resource_group.name
  location            = local.pip.location
  allocation_method   = local.pip.allocation_method

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
    private_ip_address_allocation = local.nic.ip_addr_allocation
    private_ip_address            = local.nic.ip_addr
    public_ip_address_id          = local.pip.enabled ? azurerm_public_ip.this[0].id : null
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
  name                     = local.vm.name
  computer_name            = local.vm.computer_name
  location                 = local.vm.location
  resource_group_name      = var.resource_group.name
  size                     = local.vm.size
  provision_vm_agent = true
  admin_username           = local.vm.admin_username
  admin_password           = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]

  os_disk {
    caching              = local.vm.caching
    storage_account_type = local.vm.storage_account_type
    disk_size_gb         = local.vm.disk_size_gb
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = local.vm.sku
    version   = local.vm.version
  }

  availability_set_id = local.vm.availability_set_id
  zone                = local.vm.zone

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      identity,
      tags
    ]
  }
}