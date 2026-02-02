resource "azurerm_public_ip" "this" {
  count               = var.public_ip_config.enabled ? 1 : 0
  name                = local.public_ip.name
  resource_group_name = var.resource_group_name
  location            = var.virtual_machine_config.location
  allocation_method   = var.public_ip_config.allocation_method
  zones               = var.virtual_machine_config.zone != null ? [var.virtual_machine_config.zone] : null
  sku                 = var.public_ip_config.sku

  tags = var.tags
}

resource "azurerm_network_interface" "this" {
  name                           = local.nic.name
  location                       = var.virtual_machine_config.location
  resource_group_name            = var.resource_group_name
  dns_servers                    = var.nic_config.dns_servers
  accelerated_networking_enabled = var.nic_config.enable_accelerated_networking

  ip_configuration {
    name                          = local.nic.ip_config_name
    subnet_id                     = var.subnet.id
    private_ip_address_allocation = var.nic_config.private_ip == null ? "Dynamic" : "Static"
    private_ip_address            = var.nic_config.private_ip
    public_ip_address_id          = var.public_ip_config.enabled ? azurerm_public_ip.this[0].id : null
  }
  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "this" {
  count                     = var.nic_config.nsg != null ? 1 : 0
  network_interface_id      = azurerm_network_interface.this.id
  network_security_group_id = var.nic_config.nsg.id
}

resource "azurerm_network_interface_application_security_group_association" "additional_nics" {
  count                         = var.additional_network_interface_ids != [] && var.nic_config.asg != null ? length(var.additional_network_interface_ids) : 0
  network_interface_id          = var.additional_network_interface_ids[count.index]
  application_security_group_id = var.nic_config.asg.id
}

resource "azurerm_windows_virtual_machine" "this" {
  count                      = var.is_imported ? 0 : 1
  name                       = local.virtual_machine.name
  computer_name              = var.name_overrides.hostname != null ? var.name_overrides.hostname : var.virtual_machine_config.hostname
  location                   = var.virtual_machine_config.location
  resource_group_name        = var.name_overrides.resource_group_name != null ? var.name_overrides.resource_group_name : var.resource_group_name
  size                       = var.virtual_machine_config.size
  provision_vm_agent         = var.virtual_machine_config.provision_vm_agent
  allow_extension_operations = var.virtual_machine_config.allow_extension_operations
  admin_username             = var.virtual_machine_config.admin_username
  admin_password             = var.admin_password
  enable_automatic_updates   = var.virtual_machine_config.enable_automatic_updates

  os_disk {
    name                 = local.os_disk_name
    caching              = var.virtual_machine_config.os_disk_caching
    storage_account_type = var.virtual_machine_config.os_disk_storage_type
    disk_size_gb         = var.virtual_machine_config.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.virtual_machine_config.os_publisher
    offer     = var.virtual_machine_config.os_offer
    sku       = var.virtual_machine_config.os_sku
    version   = var.virtual_machine_config.os_version
  }

  proximity_placement_group_id                           = var.virtual_machine_config.proximity_placement_group_id
  network_interface_ids                                  = concat([azurerm_network_interface.this.id], var.additional_network_interface_ids)
  availability_set_id                                    = var.virtual_machine_config.availability_set_id
  zone                                                   = var.virtual_machine_config.zone
  tags                                                   = local.virtual_machine.tags
  timezone                                               = var.virtual_machine_config.timezone
  patch_mode                                             = var.virtual_machine_config.patch_mode
  patch_assessment_mode                                  = var.virtual_machine_config.patch_assessment_mode
  vtpm_enabled                                           = var.virtual_machine_config.vtpm_enabled
  secure_boot_enabled                                    = var.virtual_machine_config.secure_boot_enabled
  bypass_platform_safety_checks_on_user_schedule_enabled = var.virtual_machine_config.bypass_platform_safety_checks_on_user_schedule_enabled

  additional_capabilities {
    ultra_ssd_enabled   = var.virtual_machine_config.additional_capabilities.ultra_ssd_enabled
    hibernation_enabled = var.virtual_machine_config.additional_capabilities.hibernation_enabled
  }

  dynamic "identity" {
    for_each = var.virtual_machine_config.identity == null ? [] : [var.virtual_machine_config.identity]
    content {
      type         = identity.value.identity_type
      identity_ids = identity.value.identity_ids
    }
  }

  boot_diagnostics {
    storage_account_uri = var.virtual_machine_config.boot_diagnostics.storage_account_uri
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      identity
    ]
  }
}

resource "azurerm_windows_virtual_machine" "imported" {
  count                      = var.is_imported ? 1 : 0
  name                       = local.virtual_machine.name
  computer_name              = var.name_overrides.hostname != null ? var.name_overrides.hostname : var.virtual_machine_config.hostname
  location                   = var.virtual_machine_config.location
  resource_group_name        = var.name_overrides.resource_group_name != null ? var.name_overrides.resource_group_name : var.resource_group_name
  size                       = var.virtual_machine_config.size
  provision_vm_agent         = var.virtual_machine_config.provision_vm_agent
  allow_extension_operations = var.virtual_machine_config.allow_extension_operations
  admin_username             = var.virtual_machine_config.admin_username
  admin_password             = var.admin_password
  enable_automatic_updates   = var.virtual_machine_config.enable_automatic_updates

  os_disk {
    name                 = local.os_disk_name
    caching              = var.virtual_machine_config.os_disk_caching
    storage_account_type = var.virtual_machine_config.os_disk_storage_type
    disk_size_gb         = var.virtual_machine_config.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.virtual_machine_config.os_publisher
    offer     = var.virtual_machine_config.os_offer
    sku       = var.virtual_machine_config.os_sku
    version   = var.virtual_machine_config.os_version
  }

  proximity_placement_group_id                           = var.virtual_machine_config.proximity_placement_group_id
  network_interface_ids                                  = concat([azurerm_network_interface.this.id], var.additional_network_interface_ids)
  availability_set_id                                    = var.virtual_machine_config.availability_set_id
  zone                                                   = var.virtual_machine_config.zone
  tags                                                   = local.virtual_machine.tags
  timezone                                               = var.virtual_machine_config.timezone
  patch_mode                                             = var.virtual_machine_config.patch_mode
  patch_assessment_mode                                  = var.virtual_machine_config.patch_assessment_mode
  vtpm_enabled                                           = var.virtual_machine_config.vtpm_enabled
  secure_boot_enabled                                    = var.virtual_machine_config.secure_boot_enabled
  bypass_platform_safety_checks_on_user_schedule_enabled = var.virtual_machine_config.bypass_platform_safety_checks_on_user_schedule_enabled

  additional_capabilities {
    ultra_ssd_enabled   = var.virtual_machine_config.additional_capabilities.ultra_ssd_enabled
    hibernation_enabled = var.virtual_machine_config.additional_capabilities.hibernation_enabled
  }

  dynamic "identity" {
    for_each = var.virtual_machine_config.identity == null ? [] : [var.virtual_machine_config.identity]
    content {
      type         = identity.value.identity_type
      identity_ids = identity.value.identity_ids
    }
  }

  boot_diagnostics {
    storage_account_uri = var.virtual_machine_config.boot_diagnostics.storage_account_uri
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      identity, source_image_reference, source_image_id, timezone, admin_username, computer_name, admin_password
    ]
  }
}

resource "azurerm_virtual_machine_extension" "disk_encryption" {
  count = var.disk_encryption != null ? 1 : 0

  name                 = "${var.virtual_machine_config.hostname}-diskEncryption"
  virtual_machine_id   = azurerm_windows_virtual_machine.this.id
  publisher            = var.disk_encryption.publisher
  type                 = var.disk_encryption.type
  type_handler_version = var.disk_encryption.type_handler_version
  tags                 = var.tags

  settings = jsonencode(var.disk_encryption.settings)
}
