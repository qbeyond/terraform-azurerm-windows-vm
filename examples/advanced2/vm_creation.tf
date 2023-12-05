module "virtual_machine" {
  source              = "qbeyond/windows-vm/azurerm"
  version             = "2.1.0"
  for_each            = local.vm_win
  subnet              = each.value.subnet
  resource_group_name = each.value.resource_group_name
  nic_config          = each.value.nic_config
  public_ip_config    = each.value.public_ip_config
  
  virtual_machine_config = {
    hostname = each.key
    size     = each.value.size
    os_sku   = each.value.os_sku
    location = each.value.location
    timezone = each.value.timezone
    
    os_version           = each.value.os_version
    os_disk_size_gb      = each.value.os_disk_size_gb
    os_disk_caching      = each.value.os_disk_caching
    os_disk_storage_type = each.value.os_disk_storage_type
    
    admin_username            = each.value.admin_username
    availability_set_id       = each.value.availability_set_id
    write_accelerator_enabled = each.value.write_accelerator_enabled
    tags                      = each.value.tags
  }

  severity_group      = each.value.severity_group
  update_allowed      = each.value.update_allowed
  data_disks          = each.value.data_disks
  admin_password      = each.value.admin_password  
  name_overrides      = each.value.name_overrides
  log_analytics_agent = azurerm_log_analytics_workspace.this
}