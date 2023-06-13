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
      zone = var.vm_config.zone
      disk_size_gb = coalesce(var.vm_config.disk_size_gb, 64)
  }
}