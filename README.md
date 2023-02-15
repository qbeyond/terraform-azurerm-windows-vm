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
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 3.6.0 |

## Inputs

No inputs.
## Outputs

No outputs.

## Resource types

| Type | Used |
|------|-------|
| [azurerm_managed_disk](https://registry.terraform.io/providers/hashicorp/azurerm/3.6.0/docs/resources/managed_disk) | 1 |
| [azurerm_network_interface](https://registry.terraform.io/providers/hashicorp/azurerm/3.6.0/docs/resources/network_interface) | 1 |
| [azurerm_network_interface_security_group_association](https://registry.terraform.io/providers/hashicorp/azurerm/3.6.0/docs/resources/network_interface_security_group_association) | 1 |
| [azurerm_public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/3.6.0/docs/resources/public_ip) | 1 |
| [azurerm_virtual_machine_data_disk_attachment](https://registry.terraform.io/providers/hashicorp/azurerm/3.6.0/docs/resources/virtual_machine_data_disk_attachment) | 1 |
| [azurerm_windows_virtual_machine](https://registry.terraform.io/providers/hashicorp/azurerm/3.6.0/docs/resources/windows_virtual_machine) | 1 |

**`Used` only includes resource blocks.** `for_each` and `count` meta arguments, as well as resource blocks of modules are not considered.

## Modules

No modules.

## Resources by Files

### main.tf

| Name | Type |
|------|------|
| [azurerm_managed_disk.disk](https://registry.terraform.io/providers/hashicorp/azurerm/3.6.0/docs/resources/managed_disk) | resource |
| [azurerm_network_interface.nic](https://registry.terraform.io/providers/hashicorp/azurerm/3.6.0/docs/resources/network_interface) | resource |
| [azurerm_network_interface_security_group_association.nic_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/3.6.0/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_public_ip.pip](https://registry.terraform.io/providers/hashicorp/azurerm/3.6.0/docs/resources/public_ip) | resource |
| [azurerm_virtual_machine_data_disk_attachment.disk_vm](https://registry.terraform.io/providers/hashicorp/azurerm/3.6.0/docs/resources/virtual_machine_data_disk_attachment) | resource |
| [azurerm_windows_virtual_machine.vm](https://registry.terraform.io/providers/hashicorp/azurerm/3.6.0/docs/resources/windows_virtual_machine) | resource |
<!-- END_TF_DOCS -->

## Contribute

Please use Pull requests to contribute.

When a new Feature or Fix is ready to be released, create a new Github release and adhere to [Semantic Versioning 2.0.0](https://semver.org/lang/de/spec/v2.0.0.html).