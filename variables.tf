variable "public_ip_config" {
  type = object({
    enabled           = bool
    allocation_method = optional(string, "Static")
  })
  default = {
    enabled = false
  }
  validation {
    condition     = contains(["Static", "Dynamic"], var.public_ip_config.allocation_method)
    error_message = "Allocation method must be Static or Dynamic"
  }
  description = <<-DOC
  ```
    enabled: Optionally select true if a public ip should be created. Defaults to false.
    allocation_method: The allocation method of the public ip that will be created. Defaults to static.      
  ```
  DOC
}

# nsg needs to be an object to use the count object in main.tf. 
variable "nic_config" {
  type = object({
    private_ip                    = optional(string)
    dns_servers                   = optional(list(string))
    enable_accelerated_networking = optional(bool, false)
    nsg = optional(object({
      id = string
    }))
  })
  default     = {}
  description = <<-DOC
  ```
    private_ip: Optioanlly specify a private ip to use. Otherwise it will  be allocated dynamically.
    dns_servers: Optionally specify a list of dns servers for the nic.
    enable_accelerated_networking: Enabled Accelerated networking (SR-IOV) on the NIC. The machine SKU must support this feature.
    nsg: Although it is discouraged you can optionally assign an NSG to the NIC. Optionally specify a NSG object.
  ```
  DOC
}

variable "additional_network_interface_ids" {
  type        = list(string)
  default     = []
  description = "List of ids for additional azurerm_network_interface."
}

variable "subnet" {
  type = object({
    id               = string
    address_prefixes = list(string)
  })
  description = "The variable takes the subnet as input and takes the id and the address prefix for further configuration."
}

variable "virtual_machine_config" {
  type = object({
    hostname                     = string
    size                         = string
    os_sku                       = string
    location                     = string
    os_version                   = optional(string, "latest")
    admin_username               = optional(string, "loc_sysadmin")
    os_disk_caching              = optional(string, "ReadWrite")
    os_disk_storage_type         = optional(string, "StandardSSD_LRS")
    os_disk_size_gb              = optional(number)
    tags                         = optional(map(string))
    timezone                     = optional(string, "UTC")
    zone                         = optional(string)
    availability_set_id          = optional(string)
    write_accelerator_enabled    = optional(bool, false)
    proximity_placement_group_id = optional(string)
    patch_assessment_mode        = optional(string, "AutomaticByPlatform")
    patch_mode                   = optional(string, "AutomaticByPlatform")
    bypass_platform_safety_checks_on_user_schedule_enabled = optional(bool, true)
  })
  validation {
    condition     = contains(["None", "ReadOnly", "ReadWrite"], var.virtual_machine_config.os_disk_caching)
    error_message = "Possible values are None, ReadOnly and ReadWrite"
  }
  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS", "StandardSSD_ZRS", "Premium_ZRS"], var.virtual_machine_config.os_disk_storage_type)
    error_message = "Possible values are Standard_LRS, StandardSSD_LRS, Premium_LRS, StandardSSD_ZRS and Premium_ZRS"
  }
  validation {
    condition     = (contains(["Premium_LRS", "Premium_ZRS"], var.virtual_machine_config.os_disk_storage_type) && var.virtual_machine_config.write_accelerator_enabled == true  && var.virtual_machine_config.os_disk_caching == "None") || (var.virtual_machine_config.write_accelerator_enabled == false)
    error_message = "write_accelerator_enabled, can only be activated on Premium disks and caching deactivated."
  }
  validation {
    condition     = var.virtual_machine_config.zone == null || var.virtual_machine_config.zone == 1 || var.virtual_machine_config.zone == 2 || var.virtual_machine_config.zone == 3
    error_message = "Zone, can only be empty, 1, 2 or 3."
  }
  description = <<-DOC
  ```
    size: The size of the vm. Possible values can be seen here: https://learn.microsoft.com/en-us/azure/virtual-machines/sizes
    os_sku: The os that will be running on the vm.
    location: The location of the virtual machine.
    os_version: Optionally specify an os version for the chosen sku. Defaults to latest.
    admin_username: Optionally choose the admin_username of the vm. Defaults to loc_sysadmin. 
      The local admin name could be changed by the gpo in the target ad.
    os_disk_caching: Optionally change the caching option of the os disk. Defaults to ReadWrite.
    os_disk_storage_type: Optionally change the os_disk_storage_type. Defaults to StandardSSD_LRS.
    os_disk_size_gb: Optionally change the size of the os disk. Defaults to be specified by image.
    tags: Optionally specify tags in as a map.
    timezone: Optionally change the timezone of the VM. Defaults to UTC.
      (More timezone names: https://jackstromberg.com/2017/01/list-of-time-zones-consumed-by-azure/).
    zone: Optionally specify an availibility zone for the vm.
    availability_set_id: Optionally specify an availibilty set for the vm.
    write_accelerator_enabled: Optionally activate write accelaration for the os disk. Can only
      be activated on Premium_LRS disks and caching deactivated. Defaults to false.
    proximity_placement_group_id: (Optional) The ID of the Proximity Placement Group which the Virtual Machine should be assigned to.
    patch_assessment_mode: Specifies the mode of VM Guest Patching for the Virtual Machine.
    patch_mode:  Specifies the mode of in-guest patching to this Windows Virtual Machine.
    bypass_platform_safety_checks_on_user_schedule_enabled: This setting ensures that machines are patched by using your configured schedules and not autopatched.
       Can only be set to true when patch_mode is set to AutomaticByPlatform.
  ```
  DOC
}

variable "severity_group" {
  type        = string
  description = "The severity group of the virtual machine. Added as value of tag `Severity Group Monthly`."
}

variable "update_allowed" {
  type        = bool
  default     = true
  description = "Set the tag `Update allowed`. `True` will set `yes`, `false` to `no`."
}

variable "admin_password" {
  type        = string
  sensitive   = true
  description = "Password of the local administrator."
}


variable "data_disks" {
  type = map(object({
    lun                        = number
    disk_size_gb               = number
    caching                    = optional(string, "ReadWrite")
    create_option              = optional(string, "Empty")
    source_resource_id         = optional(string)
    storage_account_type       = optional(string, "StandardSSD_LRS")
    write_accelerator_enabled  = optional(bool, false)
    on_demand_bursting_enabled = optional(bool, false)
  }))
  validation {
    condition     = length([for v in var.data_disks : v.lun]) == length(distinct([for v in var.data_disks : v.lun]))
    error_message = "One or more of the lun parameters in the map are duplicates."
  }
  validation {
    condition     = alltrue([for o in var.data_disks : contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS", "StandardSSD_ZRS", "Premium_ZRS"], o.storage_account_type)])
    error_message = "Possible values are Standard_LRS, StandardSSD_LRS, Premium_LRS, StandardSSD_ZRS and Premium_ZRS for storage_account_type"
  }
  validation {
    condition     = (alltrue([for o in var.data_disks : contains(["Premium_LRS", "Premium_ZRS"], o.storage_account_type)]) && alltrue([for o in var.data_disks : o.write_accelerator_enabled == true]) && alltrue([for o in var.data_disks : o.caching == "None"])) || (alltrue([for o in var.data_disks : o.write_accelerator_enabled == false]))
    error_message = "write_accelerator_enabled, can only be activated on Premium disks and caching deactivated."
  }
  validation {
    condition     = (alltrue([for o in var.data_disks : contains(["Premium_LRS", "Premium_ZRS"], o.storage_account_type)]) && alltrue([for o in var.data_disks : o.on_demand_bursting_enabled == true])) || (alltrue([for o in var.data_disks : o.on_demand_bursting_enabled == false]))
    error_message = "If enable on demand bursting, possible storage_account_type values are Premium_LRS and Premium_ZRS."
  }
  validation {
    condition     = alltrue([for o in var.data_disks : (
      (o.source_resource_id != null && contains(["Copy", "Restore"], o.create_option) || (o.create_option == "Empty" && o.source_resource_id == null))
    )])
    error_message = "When a data disk source resource ID is specified then create option must be either 'Copy' or 'Restore'."
  }
  default     = {}
  description = <<-DOC
  ```
   <logical name of the data disk> = {
    lun: Number of the lun.
    disk_size_gb: The size of the data disk.
    storage_account_type: Optionally change the storage_account_type. Defaults to StandardSSD_LRS.
    caching: Optionally activate disk caching. Defaults to None.
    create_option: Optionally change the create option. Defaults to Empty disk.
    source_resource_id: (Optional) The ID of an existing Managed Disk or Snapshot to copy when create_option is Copy or
      the recovery point to restore when create_option is Restore. Changing this forces a new resource to be created.
    write_accelerator_enabled: Optionally activate write accelaration for the data disk. Can only
      be activated on Premium disks and caching deactivated. Defaults to false.
    on_demand_bursting_enabled: Optionally activate disk bursting. Only for Premium disk. Default false.
   }
  ```
  DOC
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group where the resources will be created."
}

variable "name_overrides" {
  type = object({
    nic             = optional(string)
    nic_ip_config   = optional(string)
    public_ip       = optional(string)
    virtual_machine = optional(string)
    os_disk         = optional(string)
    data_disks      = optional(map(string), {})
  })
  description = "Possibility to override names that will be generated according to q.beyond naming convention."
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to add to the resources created in this module"
  default     = {}
}


