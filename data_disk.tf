resource "azurerm_managed_disk" "data_disk" {
  for_each = var.data_disks
  name = each.value["name"]
  location = var.virtual_machine_config.location
  resource_group_name = var.resource_group_name
  storage_account_type = each.value["storage_account_type"]
  create_option = each.value["create_option"]
  disk_size_gb = each.value["disk_size_gb"]
  zone = var.virtual_machine_config.zone
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      tags
  ]
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk" {
  for_each = var.data_disks
  managed_disk_id    = azurerm_managed_disk.data_disk[each.key].id
  virtual_machine_id = azurerm_windows_virtual_machine.this.id
  lun                = each.key
  caching            = each.value["caching"]
  write_accelerator_enabled = each.value["write_accelerator_enabled"]

  lifecycle {
  prevent_destroy = true
  }
}