# Windows VM
[![GitHub tag](https://img.shields.io/github/tag/qbeyond/terraform-azurerm-windows-vm.svg)](https://registry.terraform.io/modules/qbeyond/windows-vm/azurerm/latest)
[![License](https://img.shields.io/github/license/qbeyond/terraform-azurerm-windows-vm.svg)](https://github.com/qbeyond/terraform-azurerm-windows-vm/blob/main/LICENSE)

----

This module will create a windows virtual machine, a network interface and associates the network interface to the target subnet. Optionally one or more data disks and a public ip can be created. 

<!-- BEGIN_TF_DOCS -->
## Usage

This module provisions a windows virtual machine. Refer to the examples on how this could be done. It is a fast and easy to use deployment of a virtual machine!
#### Examples
###### Basic
```hcl
provider "azurerm" {
  features {}
}

module "virtual_machine" {
  source = "../.."
  virtual_machine_config = {
    hostname             = "CUSTAPP001"
    location             = local.location
    admin_username       = "local_admin"
    size                 = "Standard_B1s"
    os_sku               = "2022-Datacenter"
    os_version           = "latest"
    os_disk_storage_type = "Standard_LRS"
  }
  admin_password      = "H3ll0W0rld!"
  resource_group_name = azurerm_resource_group.this.name
  subnet              = azurerm_subnet.this
  severity_group      = "01-first-monday-2000-csu-reboot"
}

resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = local.location
}

resource "azurerm_virtual_network" "this" {
  name                = local.virtual_network_name
  address_space       = ["10.0.0.0/24"]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "this" {
  name                 = local.subnet_name
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.0.0/24"]
}
```
###### Advanced
```hcl
provider "azurerm" {
  features {}

  skip_provider_registration = true
}

module "virtual_machine" {
  source = "../.."
  public_ip_config = {
    enabled           = true
    allocation_method = "Static"
  }
  nic_config = {
    private_ip                    = "10.0.0.16"
    dns_servers                   = ["10.0.0.10", "10.0.0.11"]
    enable_accelerated_networking = false
    nsg                           = azurerm_network_security_group.this
  }
  virtual_machine_config = {
    hostname                     = "CUSTAPP007"
    location                     = azurerm_resource_group.this.location
    size                         = "Standard_B1s"
    os_sku                       = "2022-datacenter-g2"
    os_version                   = "latest"
    os_disk_name                 = "DiskOverride"
    os_disk_size_gb              = 128
    os_disk_caching              = "ReadWrite"
    os_disk_storage_type         = "Standard_LRS"
    os_disk_write_accelerator_enabled = false
    availability_set_id          = azurerm_availability_set.this.id
    proximity_placement_group_id = azurerm_proximity_placement_group.this.id

    admin_username               = "loc_admin"

    timezone                     = "Azores Standard Time"

    patch_assessment_mode                                  = "AutomaticByPlatform"
    patch_mode                                             = "AutomaticByPlatform"
    bypass_platform_safety_checks_on_user_schedule_enabled = true

    tags = {
      "Environment" = "prd"
    }
  }
  admin_password      = "H3ll0W0rld!"
  resource_group_name = azurerm_resource_group.this.name
  subnet              = azurerm_subnet.this
  data_disks = {
    "${local.managed_disk_name}" = {
      lun                       = 1
      caching                   = "ReadWrite"
      disk_size_gb              = 64
      create_option             = "Empty"
      storage_account_type      = "Standard_LRS"
      write_accelerator_enabled = false
    }
  }

  additional_network_interface_ids = [azurerm_network_interface.additional_nic_01.id]
  severity_group                   = "01-third-tuesday-0200-XCSUFEDTG-reboot"
  update_allowed                   = true

  name_overrides = {
    nic             = local.nic
    nic_ip_config   = local.nic_ip_config
    public_ip       = local.public_ip
    virtual_machine = local.virtual_machine
    data_disks = {
      "${local.managed_disk_name}" = "Override"
    }
  }

  tags = {
    "example" = "examplevalue"
  }
}

resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = local.location
}

resource "azurerm_virtual_network" "this" {
  name                = local.virtual_network_name
  address_space       = ["10.0.0.0/24"]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "this" {
  name                 = local.subnet_name
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_availability_set" "this" {
  name                         = local.availability_set_name
  location                     = local.location
  resource_group_name          = azurerm_resource_group.this.name
  proximity_placement_group_id = azurerm_proximity_placement_group.this.id
}

resource "azurerm_proximity_placement_group" "this" {
  name                = local.proximity_placement_group_name
  location            = local.location
  resource_group_name = azurerm_resource_group.this.name
  
  lifecycle {
      ignore_changes = [tags]
  }
}

resource "azurerm_network_interface" "additional_nic_01" {
  name                          = "nic-vm-${replace(element(azurerm_virtual_network.this.address_space,0), "/[./]/", "-")}-01"
  location                      = local.location
  resource_group_name           = azurerm_resource_group.this.name
  dns_servers                   = []

  ip_configuration {
    name                          = "ip-nic-01"
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
    private_ip_address            = null
    public_ip_address_id          = null
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_network_security_group" "this" {
  name                = local.nsg_name
  location            = local.location
  resource_group_name = azurerm_resource_group.this.name

  security_rule {
    name                       = "example"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.108 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | Password of the local administrator. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group where the resources will be created. | `string` | n/a | yes |
| <a name="input_severity_group"></a> [severity\_group](#input\_severity\_group) | The severity group of the virtual machine. Added as value of tag `Severity Group Monthly`. | `string` | n/a | yes |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | <pre>The variable takes the subnet as input and takes the id and the address prefix for further configuration.<br/>  Note: If no address prefix is provided, the information is being extracted from the id.</pre> | <pre>object({<br/>    id               = string<br/>    address_prefixes = optional(list(string), null)<br/>  })</pre> | n/a | yes |
| <a name="input_virtual_machine_config"></a> [virtual\_machine\_config](#input\_virtual\_machine\_config) | <pre>hostname: Name of the host system.<br/>  size: The size of the vm. Possible values can be seen here: https://learn.microsoft.com/en-us/azure/virtual-machines/sizes<br/>  location: The location of the virtual machine.<br/>  os_sku: The os that will be running on the vm.<br/>  os_publisher: Optionally specify the os publisher. Defaults to MicrosoftWindowsServer.<br/>  os_offer: Optionally specify the os offer. Defaults to WindowsServer.<br/>  os_version: Optionally specify an os version for the chosen sku. Defaults to latest.<br/>  os_disk_caching: Optionally change the caching option of the os disk. Defaults to ReadWrite.<br/>  os_disk_storage_type: Optionally change the os_disk_storage_type. Defaults to StandardSSD_LRS.<br/>  os_disk_size_gb: Optionally change the size of the os disk. Defaults to be specified by image.<br/>  admin_username: Optionally choose the admin_username of the vm. Defaults to loc_sysadmin.<br/>    The local admin name could be changed by the gpo in the target ad.<br/>  os_disk_write_accelerator_enabled: Optionally activate write accelaration for the os disk. Can only<br/>    be activated on Premium_LRS disks and caching deactivated. Defaults to false.<br/>  zone: Optionally specify an availibility zone for the vm, data_disks and nic.<br/>  timezone: Optionally change the timezone of the VM. Defaults to UTC.<br/>    (More timezone names: https://jackstromberg.com/2017/01/list-of-time-zones-consumed-by-azure/).<br/>  availability_set_id: Optionally specify an availibilty set for the vm.<br/>  proximity_placement_group_id: (Optional) The ID of the Proximity Placement Group which the Virtual Machine should be assigned to.<br/>  patch_assessment_mode: Specifies the mode of VM Guest Patching for the Virtual Machine.<br/>  patch_mode:  Specifies the mode of in-guest patching to this Windows Virtual Machine.<br/>  bypass_platform_safety_checks_on_user_schedule_enabled: This setting ensures that machines are patched by using your configured schedules and not autopatched.<br/>     Can only be set to true when patch_mode is set to AutomaticByPlatform.<br/>  additional_capabilities: (Optional) Additional capabilities for the virtual machine.<br/>    ultra_ssd_enabled: (Optional) Enable UltraSSD_LRS for the virtual machine. Defaults to false.<br/>    hibernation_enabled: (Optional) Enable hibernation for the virtual machine. Defaults to false.</pre> | <pre>object({<br/>    hostname                                               = string<br/>    size                                                   = string<br/>    location                                               = string<br/>    os_sku                                                 = string<br/>    os_publisher                                           = optional(string, "MicrosoftWindowsServer")<br/>    os_offer                                               = optional(string,"WindowsServer")<br/>    os_version                                             = optional(string, "latest")<br/>    os_disk_caching                                        = optional(string, "ReadWrite")<br/>    os_disk_storage_type                                   = optional(string, "StandardSSD_LRS")<br/>    os_disk_size_gb                                        = optional(number)<br/>    os_disk_write_accelerator_enabled                      = optional(bool, false)<br/>    admin_username                                         = optional(string, "loc_sysadmin")<br/>    zone                                                   = optional(string)<br/>    timezone                                               = optional(string, "UTC")<br/>    availability_set_id                                    = optional(string)<br/>    proximity_placement_group_id                           = optional(string)<br/>    patch_assessment_mode                                  = optional(string, "AutomaticByPlatform")<br/>    patch_mode                                             = optional(string, "AutomaticByPlatform")<br/>    bypass_platform_safety_checks_on_user_schedule_enabled = optional(bool, true)<br/><br/>    additional_capabilities                                = optional(object({<br/>      ultra_ssd_enabled   = optional(bool, false)<br/>      hibernation_enabled = optional(bool, false)<br/>    }), {})<br/>  })</pre> | n/a | yes |
| <a name="input_additional_network_interface_ids"></a> [additional\_network\_interface\_ids](#input\_additional\_network\_interface\_ids) | List of ids for additional azurerm\_network\_interface. | `list(string)` | `[]` | no |
| <a name="input_data_disks"></a> [data\_disks](#input\_data\_disks) | <pre>`<logical name of the data disk>` = {<br/>  lun: Number of the lun.<br/>  disk_size_gb: The size of the data disk.<br/>  storage_account_type: Optionally change the storage_account_type. Defaults to StandardSSD_LRS.<br/>  caching: Optionally activate disk caching. Defaults to None.<br/>  create_option: Optionally change the create option. Defaults to Empty disk.<br/>  source_resource_id: (Optional) The ID of an existing Managed Disk or Snapshot to copy when create_option is Copy or<br/>    the recovery point to restore when create_option is Restore. Changing this forces a new resource to be created.<br/>  write_accelerator_enabled: Optionally activate write accelaration for the data disk. Can only<br/>    be activated on Premium disks and caching deactivated. Defaults to false.<br/>  on_demand_bursting_enabled: Optionally activate disk bursting. Only for Premium disk with size to 512 Gb up. Default false.<br/>  disk_iops_read_write: (Optional) The maximum number of IOPS allowed for the disk in read/write operations.<br/>  disk_mbps_read_write: (Optional) The maximum number of MBps allowed for the disk in read/write operations.<br/>  disk_iops_read_only: (Optional) The maximum number of IOPS allowed for the disk in read-only operations.<br/>  disk_mbps_read_only: (Optional) The maximum number of MBps allowed for the disk in read-only operations.<br/>  max_shares: (Optional) The maximum number of VMs that can share this disk. Only for UltraSSD_LRS and PremiumV2_LRS disks.<br/> }</pre> | <pre>map(object({<br/>    lun                        = number<br/>    disk_size_gb               = number<br/>    caching                    = optional(string, "ReadWrite")<br/>    create_option              = optional(string, "Empty")<br/>    source_resource_id         = optional(string)<br/>    storage_account_type       = optional(string, "StandardSSD_LRS")<br/>    write_accelerator_enabled  = optional(bool, false)<br/>    on_demand_bursting_enabled = optional(bool, false)<br/>    disk_iops_read_write       = optional(number)<br/>    disk_mbps_read_write       = optional(number)<br/>    disk_iops_read_only        = optional(number)<br/>    disk_mbps_read_only        = optional(number)<br/>    max_shares                 = optional(number)<br/>  }))</pre> | `{}` | no |
| <a name="input_name_overrides"></a> [name\_overrides](#input\_name\_overrides) | Possibility to override names that will be generated according to q.beyond naming convention. | <pre>object({<br/>    nic             = optional(string)<br/>    nic_ip_config   = optional(string)<br/>    public_ip       = optional(string)<br/>    virtual_machine = optional(string)<br/>    os_disk         = optional(string)<br/>    data_disks      = optional(map(string), {})<br/>  })</pre> | `{}` | no |
| <a name="input_nic_config"></a> [nic\_config](#input\_nic\_config) | <pre>private_ip: Optioanlly specify a private ip to use. Otherwise it will  be allocated dynamically.<br/>  dns_servers: Optionally specify a list of dns servers for the nic.<br/>  enable_accelerated_networking: Enabled Accelerated networking (SR-IOV) on the NIC. The machine SKU must support this feature.<br/>  nsg: Although it is discouraged you can optionally assign an NSG to the NIC. Optionally specify a NSG object.</pre> | <pre>object({<br/>    private_ip                    = optional(string)<br/>    dns_servers                   = optional(list(string))<br/>    enable_accelerated_networking = optional(bool, false)<br/>    nsg = optional(object({<br/>      id = string<br/>    }))<br/>  })</pre> | `{}` | no |
| <a name="input_public_ip_config"></a> [public\_ip\_config](#input\_public\_ip\_config) | <pre>enabled: Optionally select true if a public ip should be created. Defaults to false.<br/>  allocation_method: The allocation method of the public ip that will be created. Defaults to static.  <br/>  zones: Optionally specify an availibility zone for the public ip. Defaults to null.    <br/>  sku: Optionally specify the sku of the public ip. Defaults to Standard.</pre> | <pre>object({<br/>    enabled           = bool<br/>    allocation_method = optional(string, "Static")<br/>    sku               = optional(string, "Standard")<br/>  })</pre> | <pre>{<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to add to the resources created in this module | `map(string)` | `{}` | no |
| <a name="input_update_allowed"></a> [update\_allowed](#input\_update\_allowed) | Set the tag `Update allowed`. `True` will set `yes`, `false` to `no`. | `bool` | `true` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_data_disks"></a> [data\_disks](#output\_data\_disks) | n/a |
| <a name="output_network_interface"></a> [network\_interface](#output\_network\_interface) | n/a |
| <a name="output_virtual_machine"></a> [virtual\_machine](#output\_virtual\_machine) | n/a |

      ## Resource types

      | Type | Used |
      |------|-------|
        | [azurerm_managed_disk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) | 1 |
        | [azurerm_network_interface](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | 1 |
        | [azurerm_network_interface_security_group_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | 1 |
        | [azurerm_public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | 1 |
        | [azurerm_virtual_machine_data_disk_attachment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) | 1 |
        | [azurerm_windows_virtual_machine](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) | 1 |

      **`Used` only includes resource blocks.** `for_each` and `count` meta arguments, as well as resource blocks of modules are not considered.
    
## Modules

No modules.

        ## Resources by Files

            ### data_disk.tf

            | Name | Type |
            |------|------|
                  | [azurerm_managed_disk.data_disk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) | resource |
                  | [azurerm_virtual_machine_data_disk_attachment.data_disk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) | resource |

            ### main.tf

            | Name | Type |
            |------|------|
                  | [azurerm_network_interface.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
                  | [azurerm_network_interface_security_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
                  | [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
                  | [azurerm_windows_virtual_machine.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) | resource |
    
<!-- END_TF_DOCS -->

## Contribute

Please use Pull requests to contribute.

When a new Feature or Fix is ready to be released, create a new Github release and adhere to [Semantic Versioning 2.0.0](https://semver.org/lang/de/spec/v2.0.0.html).
