output "os_disk_name" {
  value = module.virtual_machine.virtual_machine.os_disk[0].name
  precondition {
    condition     = module.virtual_machine.virtual_machine.os_disk[0].name == local.disk_name_os
    error_message = "The name of the os disk was not correctly generated."
  }
}
