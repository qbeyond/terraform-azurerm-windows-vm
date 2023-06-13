locals {
  public_ip = {
      enabled = var.public_ip_config.enabled
      name = coalesce(var.name_overrides.public_ip, "pip-vm-${var.virtual_machine_config.hostname}")
      location = coalesce(var.public_ip_config.location, var.resource_group.location)
      allocation_method = var.public_ip_config.allocation_method
  }

  nic = {
      name = coalesce(var.name_overrides.nic, replace(replace("nic-${var.virtual_machine_config.hostname}-${var.nic_config.subnet.address_prefixes[0]}", ".", "-"), "/", "-"))
      ip_config_name = coalesce(var.name_overrides.nic_ip_config, "internal")
      location = coalesce(var.nic_config.location, var.resource_group.location)
      dns_servers = var.nic_config.dns_servers
      subnet_id = var.nic_config.subnet.id
      ip_address_allocation = var.nic_config.private_ip == null ? "Dynamic" : "Static"
      ip_address = var.nic_config.private_ip
      nsg_id = var.nic_config.nsg_id
  }

  virtual_machine = {
      name = coalesce(var.name_overrides.virtual_machine, "vm-${var.virtual_machine_config.hostname}")
      computer_name = var.virtual_machine_config.hostname
      location = coalesce(var.virtual_machine_config.location, var.resource_group.location)
      size = var.virtual_machine_config.size
      sku = var.virtual_machine_config.os_sku
      version = var.virtual_machine_config.os_version
      admin_username = var.virtual_machine_config.admin_username
      caching = var.virtual_machine_config.os_disk_caching
      storage_account_type = var.virtual_machine_config.os_disk_storage_type #https://registry.terraform.io/providers/hashicorp/azurerm/3.41.0/docs/resources/managed_disk
      availability_set_id = var.virtual_machine_config.availability_set_id
      zone = var.virtual_machine_config.zone
      disk_size_gb = var.virtual_machine_config.os_disk_size_gb
      tags = var.virtual_machine.tags
  }
}