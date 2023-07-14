# Module
[![GitHub tag](https://img.shields.io/github/tag/qbeyond/terraform-module-template.svg)](https://registry.terraform.io/modules/qbeyond/terraform-module-template/provider/latest)
[![License](https://img.shields.io/github/license/qbeyond/terraform-module-template.svg)](https://github.com/qbeyond/terraform-module-template/blob/main/LICENSE)

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
        hostname = "CUSTAPP001"
        location = local.location
        admin_username = "local_admin"
        size = "Standard_D2_v5"
        os_sku = "2022-Datacenter"
        os_version = "latest"
    }
    admin_password = "H3ll0W0rld!"
    resource_group_name = azurerm_resource_group.this.name
    subnet = azurerm_subnet.this
}

resource "azurerm_resource_group" "this" {
  name = local.resource_group_name
  location = local.location
}

resource "azurerm_virtual_network" "this" {
  name = local.virtual_network_name
  address_space = [ "10.0.0.0/24" ]
  location = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "this" {
  name = local.subnet_name
  resource_group_name = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes = [ "10.0.0.0/24" ]
}
```
###### Advanced
```hcl
provider "azurerm" {
  features {}
}

module "virtual_machine" {
  source = "../.."
  public_ip_config = {
    enabled = true
    allocation_method = "Static"
  }
  nic_config = {
    private_ip = "10.0.0.16"
    dns_servers = [ "10.0.0.10", "10.0.0.11" ]
    nsg = azurerm_network_security_group.this
  }
  virtual_machine_config = {
    hostname = "CUSTAPP007"
    size = "Standard_D2_v5"
    os_sku = "2022-datacenter-g2"
    location = azurerm_resource_group.this.location
    availability_set_id = azurerm_availability_set.this.id
    os_version = "latest"
    admin_username = "loc_admin"
    os_disk_caching = "ReadWrite"
    os_disk_storage_type = "StandardSSD_LRS"
    os_disk_size_gb = 128
    tags = {
      "Environment" = "prd" 
    }
    write_accelerator_enabled = false
  }
  admin_password = "H3ll0W0rld!"
  resource_group_name = azurerm_resource_group.this.name
  subnet = azurerm_subnet.this
  data_disks = {
    "${local.managed_disk_name}" = {
        lun = 1
        caching = "ReadWrite"
        disk_size_gb = 64
        create_option = "Empty"
        storage_account_type = "Standard_LRS"
        write_accelerator_enabled = false
    }
  }

  log_analytics_agent = azurerm_log_analytics_workspace.this

  name_overrides = {
    nic = local.nic
    nic_ip_config = local.nic_ip_config
    public_ip = local.public_ip
    virtual_machine = local.virtual_machine
  }
}

resource "azurerm_resource_group" "this" {
  name = local.resource_group_name
  location = local.location
}

resource "azurerm_virtual_network" "this" {
  name = local.virtual_network_name
  address_space = [ "10.0.0.0/24" ]
  location = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "this" {
  name = local.subnet_name
  resource_group_name = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes = [ "10.0.0.0/24" ]
}

resource "azurerm_availability_set" "this" {
  name = local.availability_set_name
  location = local.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_network_security_group" "this" {
  name = local.nsg_name
  location = local.location
  resource_group_name = azurerm_resource_group.this.name

  security_rule {
    name = "example"
    priority = 100
    direction = "Outbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_log_analytics_workspace" "this" {
  name = local.law_name
  location = local.location
  resource_group_name = azurerm_resource_group.this.name
  sku = "PerGB2018"
  retention_in_days = 30
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.7.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | Password of the local administrator. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group where the resources will be created. | `string` | n/a | yes |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | The variable takes the subnet as input and takes the id and the address prefix for further configuration. | <pre>object ({<br>    id = string<br>    address_prefixes = list(string)<br>  })</pre> | n/a | yes |
| <a name="input_virtual_machine_config"></a> [virtual\_machine\_config](#input\_virtual\_machine\_config) | <pre>size: The size of the vm. Possible values can be seen here: https://learn.microsoft.com/en-us/azure/virtual-machines/sizes<br>  os_sku: The os that will be running on the vm.<br>  location: The location of the virtual machine.<br>  availability_set_id: Optionally specify an availibilty set for the vm.<br>  zone: Optionally specify an availibility zone for the vm. <br>  os_version: Optionally specify an os version for the chosen sku. Defaults to latest.<br>  admin_username: Optionally choose the admin_username of the vm. Defaults to loc_sysadmin. <br>    The local admin name could be changed by the gpo in the target ad.<br>  os_disk_caching: Optionally change the caching option of the os disk. Defaults to ReadWrite.<br>  os_disk_storage_type: Optionally change the os_disk_storage_type. Defaults to StandardSSD_LRS.<br>  os_disk_size_gb: Optionally change the size of the os disk. Defaults to be specified by image.<br>  tags: Optionally specify tags in as a map.<br>  write_accelerator_enabled: Optionally activate write accelaration for the os disk. Can only<br>    be activated on Premium_LRS disks and caching deactivated. Defaults to false.</pre> | <pre>object({<br>      hostname = string<br>      size = string <br>      os_sku = string<br>      location = string<br>      availability_set_id = optional(string)<br>      zone = optional(string)<br>      os_version = optional(string, "latest") <br>      admin_username = optional(string, "loc_sysadmin") <br>      os_disk_caching = optional(string, "ReadWrite")<br>      os_disk_storage_type = optional(string, "StandardSSD_LRS")<br>      os_disk_size_gb = optional(number)<br>      tags = optional(map(string)) <br>      write_accelerator_enabled = optional(bool, false) <br>  })</pre> | n/a | yes |
| <a name="input_data_disks"></a> [data\_disks](#input\_data\_disks) | <pre><name of the data disk> = {<br>  lun: Number of the lun.<br>  disk_size_gb: The size of the data disk.<br>  storage_account_type: Optionally change the storage_account_type. Defaults to StandardSSD_LRS.<br>  caching: Optionally activate disk caching. Defaults to None.<br>  create_option: Optionally change the create option. Defaults to Empty disk.<br>  write_accelerator_enabled: Optionally activate write accelaration for the data disk. Can only<br>    be activated on Premium_LRS disks and caching deactivated. Defaults to false.<br> }</pre> | <pre>map(object({<br>    lun                       = number<br>    disk_size_gb              = number<br>    storage_account_type      = optional(string, "StandardSSD_LRS")<br>    caching                   = optional(string, "None")<br>    create_option             = optional(string, "Empty")<br>    write_accelerator_enabled = optional(bool, false)<br> }))</pre> | `{}` | no |
| <a name="input_log_analytics_agent"></a> [log\_analytics\_agent](#input\_log\_analytics\_agent) | <pre>Installs the log analytics agent(MicrosoftMonitoringAgent).<br>  workspace_id: Specify id of the log analytics workspace to which monitoring data will be sent.<br>  shared_key: The Primary shared key for the Log Analytics Workspace..</pre> | <pre>object({<br>    workspace_id = string<br>    primary_shared_key = string <br>  })</pre> | `null` | no |
| <a name="input_name_overrides"></a> [name\_overrides](#input\_name\_overrides) | Possibility to override names that will be generated according to q.beyond naming convention. | <pre>object({<br>      nic = optional(string)<br>      nic_ip_config = optional(string)<br>      public_ip = optional(string)<br>      virtual_machine = optional(string)<br>  })</pre> | `{}` | no |
| <a name="input_nic_config"></a> [nic\_config](#input\_nic\_config) | <pre>private_ip: Optioanlly specify a private ip to use. Otherwise it will  be allocated dynamically.<br>  dns_servers: Optionally specify a list of dns servers for the nic. If not specified the default is the Azure DNS IP.<br>  nsg_id: Optinally specify the id of a network security group that will be assigned to the nic.</pre> | <pre>object({<br>      private_ip = optional(string)<br>      dns_servers = optional(list(string))<br>      nsg = optional(object({<br>        id = string<br>      }))<br>  })</pre> | <pre>{<br>  "dns_servers": [<br>    "168.63.129.16"<br>  ]<br>}</pre> | no |
| <a name="input_public_ip_config"></a> [public\_ip\_config](#input\_public\_ip\_config) | <pre>enabled: Optionally select true if a public ip should be created. Defaults to false.<br>  allocation_method: The allocation method of the public ip that will be created. Defaults to static.</pre> | <pre>object({<br>      enabled = bool<br>      allocation_method = optional(string, "Static")<br>  })</pre> | <pre>{<br>  "enabled": false<br>}</pre> | no |
| <a name="input_severity_group"></a> [severity\_group](#input\_severity\_group) | The severity group of the virtual machine. | `string` | `""` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_virtual_machine"></a> [virtual\_machine](#output\_virtual\_machine) | n/a |

## Resource types

| Type | Used |
|------|-------|
| [azurerm_managed_disk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) | 1 |
| [azurerm_network_interface](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | 1 |
| [azurerm_network_interface_security_group_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | 1 |
| [azurerm_public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | 1 |
| [azurerm_virtual_machine_data_disk_attachment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) | 1 |
| [azurerm_virtual_machine_extension](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | 2 |
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

### extension_azuremonitor.tf

| Name | Type |
|------|------|
| [azurerm_virtual_machine_extension.microsoftmonitoringagent](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |

### extension_dependencyagent.tf

| Name | Type |
|------|------|
| [azurerm_virtual_machine_extension.dependencyagentwindows](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |

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
