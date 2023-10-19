output "virtual_machine" {
  value = azurerm_windows_virtual_machine.this
}

output "data_disks" {
  value = azurerm_managed_disk.data_disk
}
