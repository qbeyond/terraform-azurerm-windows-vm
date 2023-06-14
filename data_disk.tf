resource "azurerm_managed_disk" "data_disk" {
  count                = length(var.data_disks)
  name                 = "${var.virtual_machine_config.hostname}-datadisk-${format("%02d", count.index)}"
  location             = local.virtual_machine.location
  resource_group_name  = var.resource_group.name
  storage_account_type = var.data_disks[count.index].storage_account_type
  create_option        = var.data_disks[count.index].create_option
  disk_size_gb         = var.data_disks[count.index].disk_size_gb
  zone                 = var.virtual_machine_config.zone == null ? null : [var.virtual_machine_config.zone]

  lifecycle {
  ignore_changes = [
    tags
  ]
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk" {
  count              = length(var.data_disks)
  managed_disk_id    = azurerm_managed_disk.data_disk[count.index].id
  virtual_machine_id = azurerm_windows_virtual_machine.this.id
  lun                = count.index
  caching            = var.data_disks.caching

  lifecycle {
  prevent_destroy = var.prevent_destroy.data_disks
  ignore_changes = [
    tags
  ]
  }
}
