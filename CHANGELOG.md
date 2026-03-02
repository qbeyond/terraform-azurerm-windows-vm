# Changelog

All notable changes to this module will be documented in this file.  
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),  
and this module adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [8.3.0] - 2025-02-02

### Added

- Added ignore_changes block to the data disk attachment for importing VM`s
- Updated import VM exmaple to reflect the new feature

## [8.2.0] - 2025-02-02

### Added

- Added name overrides for the resource group of nic, data disk and public ip
- Updated import VM exmaple to reflect the new feature

## [8.1.0] - 2025-02-02

### Added

- Updated Basic example module to have an data disk

### Fixed

- Fixed output of module, which got an error while performing "terraform plan"

## [8.0.0] - 2026-02-02

### Added

- Added provision_vm_agent, allow_extension_operations, enable_automatic_updates, boot_diagnostics and identity variable to the VM resource
- Added is_imported variable to specify a existing VM, that needs to be imported with this module. With the value true the module will ignore the following changes:
  VM: identity, source_image_reference, source_image_id, timezone, admin_username, computer_name, admin_password
  Data Disk: upload_size_bytes, create_option, source_resource_id
- Added trusted_launch_enabled to the data disk resource
- Added new example for testing imported VM`s
- Updated basic example

## [7.0.0] - 2025-11-18

### Added

- Added vtpm and secure boot variables

## [6.1.1] - 2025-10-23

### Fixed

- Fixed validation of variables which permit compatibility with module version 5.2 and up.

## [6.1.0] - 2025-10-03

### Added

- Capability to set specific tags to datadisks

## [6.0.0] - 2025-08-27

### Changed

- azurerm version to ~> 4.0

## [5.4.0] - 2025-08-07

### Added

- Feature for additional nics
- Tags for the disk encryption

### Fixed

- Fixed example for pip zones

## [5.3.0] - 2025-07-31

### Added

- Optional disk encryption support for Windows VMs, allowing users to enable Key Vault–based encryption.

## [5.2.0] - 2025-07-15

### Added

- Support for PremiumV2_LRS & UltraSSD_LRS storage account type (data disk).
- Validations for the PremiumV2_LRS & UltraSSD_LRS data disks, Caching, On Demand Bursting Enabled, Write Acceleration, Disks Iops & Disks Mbps.
- Variable "zones" & "sku" to the public_ip_config block with its validations.
- "os_publisher", "os_offer" & "additional_capabilities" to the virtual_machine_config" block.

### Changed

- In newer Azure provider versions, sku in public_ip_config defaults to "Standard" instead of "Basic". As a result, this optional variable was explicitly added with the default value set to "Standard"

### Note

- Requires recent Terraform versions to run the built-in validations successfully. (At least Terraform v.1.12.0)

## [5.1.0] - 2025-02-27

### Added

- address prefixes will be extracted from the subnet id if not specified
- validation of the subnet id to match naming convention if no address prefix is specified

### Note

- Requires recent Terraform versions to run the built-in validations successfully. (At least Terraform v.1.12.0)

## [5.0.4] - 2025-02-26

Bugfix to allow azurerm to use minor version upgrades.

## [5.0.3] - 2025-02-26

Fixes too low version constraint due to parameter `accelerated_networking_enabled`.

## [5.0.2] - 2025-02-25

Bugfix in type validation of `virtual_machine_config.zone`.

## [5.0.1] - 2024-10-29

Bugfix to make update management work again by default.

### Changed

- Set var.virtual_machine_config.bypass_platform_safety_checks_on_user_schedule_enabled to true

## [5.0.0] - 2024-08-30

Added new features, variable change name and disk name validation.

### Added

Support:

- Support multiples network interfaces (NICs).
- NICs accelearate networking.
- Proximity placement group.
- Source resource ID for disk when create from copy or recovery.
- Disk validation of Logical Name can't contain a '-'

### Changed

- Variable name for os disk write_accelerator_enabled.

## [4.1.0] - 2024-05-07

### Added

- Set tags at all resources created in this repository that support tags
- Output of the created network interface

### Removed

- removed "ignore changes" for tags

## [4.0.0] - 2024-03-18

### Added

### Changed

- fixed README title

### Removed

- removed old mma

## [3.0.0] - 2024-02-08

### Upgrade

Please note, that this upgrade makes the above properties managed by terraform. Therefore outside changes will be reverted by terraform from now on.

To upgrade to this new major version from `2.x` without changes to VMs (and therefore not supporting Update Manager) do:

1. Set variables

    - `patch_assessment_mode="ImageDefault"`
    - `patch_mode="AutomaticByOS"`
    - `bypass_platform_safety_checks_on_user_schedule_enabled=false`
    - `severity_group=""` if not already set

1. Run `terraform plan` and check if the values of the VM planned to change

    - If the values of the properties are planned to change, use actual values instead of the above

### Added

- `virtual_machine_config`: add support for the `patch_assessment_mode`, `patch_mode`properties
  - Defaults to `AutomaticByPlatform` as a prerequisite to use Update manager
- `virtual_machine_config`: add support for the `bypass_platform_safety_checks_on_user_schedule_enabled` property
  - Default to `true` as a prerequisite to use Update manager

### Changed

- increased minimum `azurerm` version contraint to `3.7.0` to support patching properties

### Removed

- default value for `severity_group` to encourage use of update management

## [2.1.0] - 2023-11-21

Apply a default timezone for VM configuration. Default value: UTC

### Added

- timezone as virtual maching config variable. Default: UTC

## [2.0.0] - 2023-10-18

Apply a default naming convention for disks. To upgrade to the new version from a previous version, use the `os_disk` and `data_disks` of `name_overrides` to avoid recreating the disks.

### Added

- default naming of Os disk (`disk-<hostname>-Os`)
- Default naming of data disks (`disk-<hostname>-<logical name>`)
- allow override of OsDisk and Data Disk names

## [1.1.1] - 2023-10-17

### Added

### Changed

### Removed

- removed ignore_changes for tags in the windows virtual machine resource

### Fixed

- you can now add tags also after initial deployment, they are not ignored anymore
