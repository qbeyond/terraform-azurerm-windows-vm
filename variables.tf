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
}

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
      disk_caching = optional(string)
      disk_storage_type = optional(string)
      disk_size_gb = optional(number)
  })
}

variable "extra_disk" {
  type = object({
    enabled = bool
    storage_type = optional(string)
    caching = optional(string)
    size_gb = number
  })
  default = {
    enabled = false
    size_gb = 0
  }
}

variable "admin_password" {
  type = string
  sensitive = true
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
  default = {}
}
