# Module
[![GitHub tag](https://img.shields.io/github/tag/qbeyond/terraform-module-template.svg)](https://registry.terraform.io/modules/qbeyond/terraform-module-template/provider/latest)
[![License](https://img.shields.io/github/license/qbeyond/terraform-module-template.svg)](https://github.com/qbeyond/terraform-module-template/blob/main/LICENSE)

----

This is a template module. It just showcases how a module should look. This would be a short description of the module.

<!-- BEGIN_TF_DOCS -->
## Usage

It's very easy to use!
```hcl

```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.7.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | n/a | `string` | n/a | yes |
| <a name="input_nic_config"></a> [nic\_config](#input\_nic\_config) | n/a | <pre>object({<br>      subnet = any<br>      location = optional(string)<br>      private_ip = optional(string)<br>      dns_servers = optional(list(string))<br>      nsg_id = optional(string)<br>  })</pre> | n/a | yes |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | n/a | `any` | n/a | yes |
| <a name="input_vm_config"></a> [vm\_config](#input\_vm\_config) | n/a | <pre>object({<br>      hostname = string<br>      admin_username = string<br>      size = any<br>      os_sku = string<br>      os_version = string<br>      location = optional(string)<br>      availability_set_id = optional(string)<br>      disk_caching = optional(string)<br>      disk_storage_type = optional(string)<br>      disk_size_gb = optional(number)<br>  })</pre> | n/a | yes |
| <a name="input_extra_disk"></a> [extra\_disk](#input\_extra\_disk) | n/a | <pre>object({<br>    enabled = bool<br>    storage_type = optional(string)<br>    caching = optional(string)<br>    size_gb = number<br>  })</pre> | <pre>{<br>  "enabled": false,<br>  "size_gb": 0<br>}</pre> | no |
| <a name="input_name_overrides"></a> [name\_overrides](#input\_name\_overrides) | n/a | <pre>object({<br>      nic = optional(string)<br>      nic_ip_config = optional(string)<br>      pip = optional(string)<br>      vm = optional(string)<br>      extra_disk = optional(string)<br>  })</pre> | `{}` | no |
| <a name="input_pip_config"></a> [pip\_config](#input\_pip\_config) | n/a | <pre>object({<br>      enabled = bool<br>      allocation_method = optional(string)<br>      location = optional(string)<br>      domain_name_label = optional(string)<br>  })</pre> | <pre>{<br>  "enabled": false<br>}</pre> | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vm"></a> [vm](#output\_vm) | n/a |

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

### main.tf

| Name | Type |
|------|------|
| [azurerm_managed_disk.disk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) | resource |
| [azurerm_network_interface.nic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_security_group_association.nic_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_public_ip.pip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_virtual_machine_data_disk_attachment.disk_vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) | resource |
| [azurerm_windows_virtual_machine.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) | resource |
<!-- END_TF_DOCS -->

## Contribute

Please use Pull requests to contribute.

When a new Feature or Fix is ready to be released, create a new Github release and adhere to [Semantic Versioning 2.0.0](https://semver.org/lang/de/spec/v2.0.0.html).