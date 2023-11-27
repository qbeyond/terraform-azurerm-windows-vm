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
    enabled: Optionally select true if a basic public ip should be created. Defaults to false.
    allocation_method: Static or Dynamic allocation method of the public ip. Defaults to Static.      
  ```
  DOC
}

# nsg needs to be an object to use the count object in main.tf. 
variable "nic_config" {
  type = object({
    private_ip  = optional(string)
    dns_servers = optional(list(string))
    nsg = optional(object({
      id = string
    }))
  })
  default     = {}
  description = <<-DOC
  ```
    private_ip: Optionally specify a static private IP to use. Otherwise it will be allocated dynamically by Azure.
    dns_servers: Optionally specify a list of dns servers for the nic.
    nsg_id: Although it is discouraged you can optionally assign an NSG by resource ID to this NIC.
  ```
  DOC
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
    hostname                  = string
    size                      = string
    os_sku                    = string
    location                  = string
    availability_set_id       = optional(string)
    zone                      = optional(string)
    os_version                = optional(string, "latest")
    admin_username            = optional(string, "loc_sysadmin")
    os_disk_caching           = optional(string, "ReadWrite")
    os_disk_storage_type      = optional(string, "StandardSSD_LRS")
    os_disk_size_gb           = optional(number)
    tags                      = optional(map(string))
    timezone                  = optional(string, "UTC")
    write_accelerator_enabled = optional(bool, false)
  })
  validation {
    condition     = contains(["None", "ReadOnly", "ReadWrite"], var.virtual_machine_config.os_disk_caching)
    error_message = "Possible values for os_disk_caching are None, ReadOnly and ReadWrite"
  }
  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS", "StandardSSD_ZRS", "Premium_ZRS"], var.virtual_machine_config.os_disk_storage_type)
    error_message = "Possible values for os_disk_storage_type are Standard_LRS, StandardSSD_LRS, Premium_LRS, StandardSSD_ZRS and Premium_ZRS"
  }
  description = <<-DOC
  ```
    size: The size of the VM. Possible values can be seen here: https://learn.microsoft.com/en-us/azure/virtual-machines/sizes
    os_sku: The OS that will be running on the VM. E.g. 2022-Datacenter.
    location: The location of the virtual machine.
    availability_set_id: Optionally specify an availibilty set by ID for the VM.
    zone: Optionally specify an availibility zone for the VM. 
    os_version: Optionally specify an OS version for the chosen SKU. Defaults to latest.
    admin_username: Optionally choose the admin_username of the VM. Defaults to loc_sysadmin. 
      The local admin name could potentially change due to a GPO in the target Active Directory.
    os_disk_caching: Optionally change the caching option of the OS disk. Defaults to ReadWrite.
    os_disk_storage_type: Optionally change the os_disk_storage_type. Defaults to StandardSSD_LRS.
    os_disk_size_gb: Optionally change the size of the OS disk. Defaults to the size specified by the SKU image.
    tags: Optionally specify resource tags for the VM.
    timezone: Optionally change the timezone of the VM. Defaults to UTC. More timezone names: https://jackstromberg.com/2017/01/list-of-time-zones-consumed-by-azure/
    write_accelerator_enabled: Optionally activate write accelaration for the OS disk. Can only be activated when using Premium_LRS disk and caching deactivated. Defaults to false.
  ```
  DOC
}

variable "severity_group" {
  type        = string
  default     = ""
  description = "The severity group of the VM used for scheduling updates. This sets the 'Severity Group Monthly' tag."
}

variable "update_allowed" {
  type        = bool
  default     = true
  description = "This setting controls the 'Update allowed' tag. Where 'true` is 'yes' and 'false' is 'no'. Defaults to true."
}

variable "admin_password" {
  type        = string
  sensitive   = true
  description = "Password of the local administrator."
}


variable "data_disks" {
  type = map(object({
    lun                       = number
    disk_size_gb              = number
    storage_account_type      = optional(string, "StandardSSD_LRS")
    caching                   = optional(string, "None")
    create_option             = optional(string, "Empty")
    write_accelerator_enabled = optional(bool, false)
  }))
  validation {
    condition     = length([for v in var.data_disks : v.lun]) == length(distinct([for v in var.data_disks : v.lun]))
    error_message = "One or more of the lun parameters in the map are duplicates."
  }
  default     = {}
  description = <<-DOC
  ```
   <logical name of the data disk> = {
    lun: Number of the lun.
    disk_size_gb: The size of this data disk.
    storage_account_type: Optionally change the storage_account_type. Defaults to StandardSSD_LRS.
    caching: Optionally activate disk caching. Defaults to None.
    create_option: Optionally change the create option. Defaults to Empty disk.
    write_accelerator_enabled: Optionally activate write accelaration for the data disk. Can only be activated on Premium_LRS disks and caching deactivated. Defaults to false.
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
  description = "Possibility to override the default names generated from the q.beyond naming convention."
  default     = {}
}

variable "log_analytics_agent" {
  type = object({
    workspace_id       = string
    primary_shared_key = string
  })
  sensitive   = true
  default     = null
  description = <<-DOC
  ```
    Installs the log analytics agent (MicrosoftMonitoringAgent) when specified.
    workspace_id: Specify the ID of the log analytics workspace to which monitoring data will be sent.
    shared_key: The primary/secondary shared key for the log analytics workspace.
  ```
  DOC
}
