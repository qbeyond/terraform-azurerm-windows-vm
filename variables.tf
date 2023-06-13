variable "public_ip_config" {
  type = object({
      enabled = bool
      allocation_method = optional(string, "Static")
      location = optional(string)
  })
  default = {
    enabled = false
  }
  validation {
    condition = var.public_ip_config.allocation_method == null || var.public_ip_config.allocation_method in [
      Static, 
      Dynamic
    ]
  }
  description = "All the information needed for the creation of a public ip. As default no public ip will be created."
}

variable "nic_config" {
  type = object({
      subnet = any
      location = optional(string)
      private_ip = optional(string)
      dns_servers = optional(list(string))
      nsg_id = optional(string)
  })
  description = "All the Information needed for the creation of the network interface."
}

variable "virtual_machine_config" {
  type = object({
      hostname = string
      admin_username = string
      size = any
      os_sku = string
      os_version = string
      location = optional(string)
      availability_set_id = optional(string)
      zone = optional(string)
      os_disk_caching = optional(string, "ReadWrite")
      os_disk_storage_type = optional(string, "Standard_LRS")
      os_disk_size_gb = optional(number, 64)
      tags = optional(map(string))
  })
  validation {
    condition = var.virtual_machine_config.disk_caching == null || var.virtual_machine_config.disk_caching in [
      None,
      ReadOnly,
      ReadWrite
    ]
  }
  description =   description = "All the Information needed for the creation of the virtual machine."
}

variable "admin_password" {
  type = string
  sensitive = true
  description = "Password of the local administrator."
}


variable "data_disks" {
  type = list(object({
    disk_size_gb              = number
    storage_account_type      = string
    caching                   = optional(string, "None")
    create_option             = optional(string, "Empty")
  }))
    description = "All need data for data disk creation."
}

variable "resource_group" {
  type = any
  description = "Resource Group in which the resources are created."
}

variable "name_overrides" {
  type = object({
      nic = optional(string)
      nic_ip_config = optional(string)
      public_ip = optional(string)
      virtual_machine = optional(string)
  })
  description = "Possibility to override names that will be generated according to our naming convention."
}

variable "law_monitoranddiagnostics_workspace_id" {
  type = string
  default = null 
  description = "ID of the log analytics workspace to wich date will be send from the monitoring agent extension"
}

variable "law_monitoranddiagnostics_primary_shared_key" {
  type = string
  sensitive = true 
  default = null
  description = "Shared key of the log analytics workspace to wich date will be send from the monitoring agent extension"

}