### variables without defaults ###

variable "pip_config" {
  type = object({
      enabled = bool
      allocation_method = optional(string)
      location = optional(string)
      domain_name_label = optional(string)
  })
  default = {
    enabled = false
  }
  validation {
    condition = var.pip_config.allocation_method == null || var.pip_config.allocation_method in [
      Static, 
      Dynamic
    ]
  }
}

### variables with default ###

variable "nic_config" {
  type = object({
      subnet = any
      location = optional(string)
      private_ip = optional(string)
      dns_servers = optional(list(string))
      nsg_id = optional(string)
  })
}

variable "vm_config" {
  type = object({
      hostname = string
      admin_username = string
      size = any
      os_sku = string
      os_version = string
      location = optional(string)
      availability_set_id = optional(string)
      zone = optional(string)
      disk_caching = optional(string, "ReadWrite")
      disk_storage_type = optional(string)
      disk_size_gb = optional(number)
      tags = optional(map(string))
  })
  validation {
    condition = var.vm_config.disk_caching == null || var.vm_config.disk_caching in [
      None,
      ReadOnly,
      ReadWrite
    ]
  }
}

variable "admin_password" {
  type = string
  sensitive = true
}

variable "data_disks" {
  description = "All need data for data disk creation"
  type = list(object({
    disk_size_gb              = number
    storage_account_type      = string
    caching                   = optional(string, "None")
    create_option             = optional(string, "Empty")
  }))
}

variable "resource_group" {
  type = any
}

variable "name_overrides" {
  type = object({
      nic = optional(string)
      nic_ip_config = optional(string)
      pip = optional(string)
      vm = optional(string)
      extra_disk = optional(string)
  })
}

variable "law_monitoranddiagnostics_workspace_id" {
  type = string
  default = null 
}

variable "law_monitoranddiagnostics_primary_shared_key" {
  type = string
  sensitive = true 
  default = null
}