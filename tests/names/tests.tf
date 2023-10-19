output "os_disk_name" {
  value = module.virtual_machine.virtual_machine.os_disk[0].name
  precondition {
    condition     = module.virtual_machine.virtual_machine.os_disk[0].name == local.disk_name_os
    error_message = "The name of the os disk was not correctly generated."
  }
}

output "data_disk_names" {
  value = keys(module.virtual_machine.data_disks)

  precondition {
    condition     = alltrue([for key, data_disk in module.virtual_machine.data_disks : local.data_disk_names[key] == data_disk.name])
    error_message = "One name of the data disk was not correctly generated."
  }
}
