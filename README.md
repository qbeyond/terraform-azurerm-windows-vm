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
    hostname                          = "CUSTAPP007"
    location                          = azurerm_resource_group.this.location
    size                              = "Standard_B1s"
    os_sku                            = "2022-datacenter-g2"
    os_version                        = "latest"
    os_disk_name                      = "DiskOverride"
    os_disk_size_gb                   = 128
    os_disk_caching                   = "ReadWrite"
    os_disk_storage_type              = "Standard_LRS"
    os_disk_write_accelerator_enabled = false
    availability_set_id               = azurerm_availability_set.this.id
    proximity_placement_group_id      = azurerm_proximity_placement_group.this.id

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

| Name                          | Description | Type | Default | Required |
|-------------------------------|-------------|------|---------|----------|
| `admin_password`              | Password of the local administrator. | `string` | n/a | yes |
| `resource_group_name`         | Name of the resource group where the resources will be created. | `string` | n/a | yes |
| `severity_group`              | The severity group of the virtual machine. Added as value of tag `Severity Group Monthly`. | `string` | n/a | yes |
| `subnet`                      | The variable takes the subnet as input and extracts the ID and address prefix. If no address prefix is provided, it is extracted from the ID. | <pre>object({<br/>  id               = string<br/>  address_prefixes = optional(list(string), null)<br/>})</pre> | n/a | yes |
| `virtual_machine_config`      | Configuration of the virtual machine. See full structure and defaults below. | <pre>object({<br/>  hostname                          = string<br/>  size                              = string<br/>  location                          = string<br/>  os_sku                            = string<br/>  os_publisher                      = optional(string, "MicrosoftWindowsServer")<br/>  os_offer                          = optional(string, "WindowsServer")<br/>  os_version                        = optional(string, "latest")<br/>  os_disk_caching                   = optional(string, "ReadWrite")<br/>  os_disk_storage_type              = optional(string, "StandardSSD_LRS")<br/>  os_disk_size_gb                   = optional(number)<br/>  os_disk_write_accelerator_enabled = optional(bool, false)<br/>  admin_username                    = optional(string, "loc_sysadmin")<br/>  zone                              = optional(string)<br/>  timezone                          = optional(string, "UTC")<br/>  availability_set_id               = optional(string)<br/>  proximity_placement_group_id      = optional(string)<br/>  patch_assessment_mode             = optional(string, "AutomaticByPlatform")<br/>  patch_mode                        = optional(string, "AutomaticByPlatform")<br/>  bypass_platform_safety_checks_on_user_schedule_enabled = optional(bool, true)<br/>})</pre> | n/a | yes |
| `additional_network_interface_ids` | List of IDs for additional `azurerm_network_interface`. | `list(string)` | `[]` | no |
| `data_disks`                  | Map of logical disk names and their configurations. Each entry defines the settings for a managed data disk. | <pre>map(object({<br/>  lun                        = number<br/>  disk_size_gb               = number<br/>  zone                       = optional(string)<br/>  caching                    = optional(string, "ReadWrite")<br/>  create_option              = optional(string, "Empty")<br/>  source_resource_id         = optional(string)<br/>  storage_account_type       = optional(string, "StandardSSD_LRS")<br/>  write_accelerator_enabled  = optional(bool, false)<br/>  on_demand_bursting_enabled = optional(bool, false)<br/>  disk_iops_read_write       = optional(number)<br/>  disk_mbps_read_write       = optional(number)<br/>  disk_iops_read_only        = optional(number)<br/>  disk_mbps_read_only        = optional(number)<br/>  max_shares                 = optional(number)<br/>}))</pre> | `{}` | no |
| `name_overrides`              | Possibility to override names generated according to q.beyond naming convention. | <pre>object({<br/>  nic             = optional(string)<br/>  nic_ip_config   = optional(string)<br/>  public_ip       = optional(string)<br/>  virtual_machine = optional(string)<br/>  os_disk         = optional(string)<br/>  data_disks      = optional(map(string), {})<br/>})</pre> | `{}` | no |
| `nic_config`                  | Configuration for NIC settings like private IP, DNS servers, and NSG. | <pre>object({<br/>  private_ip                     = optional(string)<br/>  dns_servers                    = optional(list(string))<br/>  enable_accelerated_networking = optional(bool, false)<br/>  nsg = optional(object({<br/>    id = string<br/>  }))<br/>})</pre> | `{}` | no |
| `public_ip_config`           | Configure public IP creation, allocation method, zones and SKU. | <pre>object({<br/>  enabled           = bool<br/>  allocation_method = optional(string, "Static")<br/>  zones             = optional(list(string))<br/>  sku               = optional(string, "Standard")<br/>})</pre> | <pre>{<br/>  "enabled": false<br/>}</pre> | no |
| `tags`                       | A mapping of tags to add to the resources created in this module. | `map(string)` | `{}` | no |
| `update_allowed`             | Set the tag `Update allowed`. `True` sets `yes`, `false` sets `no`. | `bool` | `true` | no |

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
