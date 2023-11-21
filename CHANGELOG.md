# Changelog
All notable changes to this module will be documented in this file.
 
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this module adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
 
## [Unreleased]

# [2.0.1] - 2023-11-21

Apply a default timezone for VM configuration. Default value: UTC

### Added

- timezone as virtual maching config variable. Default: UTC

# [2.0.0] - 2023-10-18

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