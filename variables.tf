variable "public_ip_config" {
  type = object({
      enabled = bool
      allocation_method = optional(string, "Static")
  })
  default = {
    enabled = false
  }
  validation {
    condition =  contains(["Static","Dynamic"], var.public_ip_config.allocation_method)
    error_message = "Allocation method must be Static or Dynamic"
  }
  description = <<-DOC
  ```
   "public_ip_config" = {
    enabled: Optionally select true if a public ip should be created. Defaults to false.
    allocation_method: The allocation method of the public ip that will be created. Defaults to static.      
   }
  ```
  DOC
} 


variable "nic_config" {
  type = object({
      private_ip = optional(string)
      dns_servers = optional(list(string))
      nsg_id = optional(string)
      nsg_link = optional(bool)
  })
  default = {}
  description = <<-DOC
  ```
   "nic_config" = {
    private_ip: Optioanlly specify a private ip to use. Otherwise it will  be allocated dynamically.
    dns_servers: Optionally specify a list of dns servers for the nic.
    nsg_id: Optinally specify the id of a network security group that will be assigned to the nic.    
   }
  ```
  DOC
}

variable "subnet" {
  type = object ({
    id = string
    address_prefixes = list(string)
  })
  description = "The variable takes the subnet as input and takes the id and the address prefix for further configuration."
  }

variable "virtual_machine_config" {
  type = object({
      hostname = string
      size = string 
      os_sku = string
      location = string
      availability_set_id = optional(string)
      zone = optional(string)
      os_version = optional(string, "latest") 
      admin_username = optional(string, "loc_sysadmin") 
      os_disk_caching = optional(string, "ReadWrite")
      os_disk_storage_type = optional(string, "StandardSSD_LRS")
      os_disk_size_gb = optional(number, 127)
      tags = optional(map(string)) 
      write_accelerator_enabled = optional(bool, false) 
  })
  validation {
    condition = contains(["None", "ReadOnly", "ReadWrite"], var.virtual_machine_config.os_disk_caching)
    error_message = "Possible values are None, ReadOnly and ReadWrite" 
  }
  validation {
    condition = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS", "StandardSSD_ZRS", "Premium_ZRS"],var.virtual_machine_config.os_disk_storage_type)
    error_message = "Possible values are Standard_LRS, StandardSSD_LRS, Premium_LRS, StandardSSD_ZRS and Premium_ZRS"
  }
  description = <<-DOC
  ```
   "virtual_machine_config" = {
    size: The size of the vm. Possible values can be seen here: https://learn.microsoft.com/en-us/azure/virtual-machines/sizes
    os_sku: The os that will be running on the vm.
    location: The location of the virtual machine.
    availability_set_id: Optionally specify an availibilty set for the vm.
    zone: Optionally specify an availibility zone for the vm. 
    os_version: Optionally specify an os version for the chosen sku. Defaults to latest.
    admin_username: Optionally choose the admin_username of the vm. Defaults to loc_sysadmin. 
      The local admin name could be changed by the gpo in the target ad.
    os_disk_caching: Optionally change the caching option of the os disk. Defaults to ReadWrite.
    os_disk_storage_type: Optionally change the os_disk_storage_type. Defaults to StandardSSD_LRS.
    os_disk_size_gb: Optionally change the size of the os disk. Defaults to 64 gb.
    tags: Optionally specify tags in as a map.
    write_accelerator_enabled: Optionally activate write accelaration for the os disk. Can only
      be activated on Premium_LRS disks and caching deactivated. Defaults to false.
   }
  ```
  DOC
}

variable "severity_group" {
  type = string
  #validation = regex(yeah)
  default = ""
  description = "The severity group of the virtual machine."
}

variable "admin_password" {
  type = string
  sensitive = true
  description = "Password of the local administrator."
}


variable "data_disks" { # change to map of objects
  type = map(object({
    name                      = string
    disk_size_gb              = number
    storage_account_type      = optional(string, "StandardSSD_LRS")
    caching                   = optional(string, "None")
    create_option             = optional(string, "Empty")
    write_accelerator_enabled = optional(bool, false)
 }))
  default = {}
  validation {
    condition = alltrue([ for key in keys(var.data_disks): can(parseint(key, 10)) ])
    error_message = "Data Disk Key must be a number."
  }
  description = <<-DOC
  ```
   "data_disks" = {
    name: Specify the name of the data disk.
    disk_size_gb: The size of the data disk.
    storage_account_type: Optionally change the storage_account_type. Defaults to StandardSSD_LRS.
    caching: Optionally activate disk caching. Defaults to None.
    create_option: Optionally change the create option. Defaults to Empty disk.
    write_accelerator_enabled: Optionally activate write accelaration for the data disk. Can only
      be activated on Premium_LRS disks and caching deactivated. Defaults to false.
   }
  ```
  DOC
}

variable "resource_group_name" {
  type = string
  description = "Name of the resource group where the resources will be created."
}

variable "name_overrides" {
  type = object({
      nic = optional(string)
      nic_ip_config = optional(string)
      public_ip = optional(string)
      virtual_machine = optional(string)
  })
  description = "Possibility to override names that will be generated according to q.beyond naming convention."
  default = {}
}

variable "law_config" {
  type = object({
    workspace_id = string
    shared_key = string
  })
  sensitive = true 
  default = null
  description = <<-DOC
  ```
   "law_config" = {
    workspace_id: Specify id of the log analytics workspace to which moniring data will be sent.
    shared_key: The shared_key to of the log analytics workspace.
  ```
  DOC
}