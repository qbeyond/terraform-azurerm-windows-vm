terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.6.0"
    }
  }
}

locals {
  pip = {
      enabled = var.pip_config.enabled
      name = coalesce(var.name_overrides.pip, "pip-vm-${var.vm_config.hostname}")
      location = coalesce(var.pip_config.location, var.resource_group.location)
      allocation_method = coalesce(var.pip_config.allocation_method, "Static")
  }

  nic = {
      name = coalesce(var.name_overrides.nic, replace(replace("nic-${var.vm_config.hostname}-${var.nic_config.subnet.address_prefixes[0]}", ".", "-"), "/", "-"))
      ip_config_name = coalesce(var.name_overrides.nic_ip_config, "internal")
      location = coalesce(var.nic_config.location, var.resource_group.location)
      dns_servers = var.nic_config.dns_servers
      subnet_id = var.nic_config.subnet.id
      ip_addr_allocation = var.nic_config.private_ip == null ? "Dynamic" : "Static"
      ip_addr = var.nic_config.private_ip
      nsg_id = var.nic_config.nsg_id
  }

  vm = {
      name = coalesce(var.name_overrides.vm, "vm-${var.vm_config.hostname}")
      computer_name = var.vm_config.hostname
      location = coalesce(var.vm_config.location, var.resource_group.location)
      size = var.vm_config.size
      sku = var.vm_config.os_sku
      version = var.vm_config.os_version
      admin_username = var.vm_config.admin_username
      caching = coalesce(var.vm_config.disk_caching, "ReadWrite")
      storage_account_type = coalesce(var.vm_config.disk_storage_type, "Standard_LRS") #https://registry.terraform.io/providers/hashicorp/azurerm/3.41.0/docs/resources/managed_disk
      availability_set_id = var.vm_config.availability_set_id
      disk_size_gb = coalesce(var.vm_config.disk_size_gb, 128)
  }

  disk = {
    enabled = var.extra_disk.enabled
    name = coalesce(var.name_overrides.extra_disk, "vm-${var.vm_config.hostname}_ExtraDisk_01")
    size_gb = var.extra_disk.size_gb
    caching = coalesce(var.extra_disk.caching, "ReadWrite")
    storage_account_type = coalesce(var.extra_disk.storage_type, "Standard_LRS")
  }
}

resource "azurerm_public_ip" "pip" {
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

resource "azurerm_network_interface" "nic" {
  name                = local.nic.name
  location            = local.nic.location
  resource_group_name = var.resource_group.name
  dns_servers         = local.nic.dns_servers

  ip_configuration {
    name                          = local.nic.ip_config_name
    subnet_id                     = local.nic.subnet_id
    private_ip_address_allocation = local.nic.ip_addr_allocation
    private_ip_address            = local.nic.ip_addr
    public_ip_address_id          = local.pip.enabled ? azurerm_public_ip.pip[0].id : null
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  count = local.nic.nsg_id == null ? 0 : 1
  network_interface_id = azurerm_network_interface.nic.id
  network_security_group_id = local.nic.nsg_id
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                     = local.vm.name
  computer_name            = local.vm.computer_name
  location                 = local.vm.location
  resource_group_name      = var.resource_group.name
  size                     = local.vm.size
  provision_vm_agent = true
  admin_username           = local.vm.admin_username
  admin_password           = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.nic.id,
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

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      identity,
      tags
    ]
  }
}

resource "azurerm_managed_disk" "disk" {
  count                = local.disk.enabled ? 1 : 0
  name                 = local.disk.name
  location             = local.vm.location
  resource_group_name  = var.resource_group.name
  storage_account_type = local.disk.storage_account_type
  create_option        = "Empty"
  disk_size_gb         = local.disk.size_gb

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "disk_vm" {
  count              = local.disk.enabled ? 1 : 0
  managed_disk_id    = azurerm_managed_disk.disk[0].id
  virtual_machine_id = azurerm_windows_virtual_machine.vm.id
  lun                = "10"
  caching            = local.disk.caching
}
