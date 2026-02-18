# How to use this example:
# 1. Create a Windows VM in Azure with the Basic example.
# 2. Fill in the subscription_id in the provider block of this example and adjust the import blocks to match the existing Resources.
# 3. Run this example and try to import the existing VM into the state file of this example.
# 4. If all resources get imported successfully, the Module works as intended.
# (There are two error build in to test the correction of the name_overrides. The hostname and RG name)
provider "azurerm" {
  subscription_id = "<Subscription ID>" # <-- Fill in Subscription ID
  features {}
}

module "virtual_machine" {
  source      = "../.."
  is_imported = true
  virtual_machine_config = {
    hostname             = "CUSTAPP002"
    location             = local.location
    admin_username       = "local_admin"
    size                 = "Standard_B1s"
    os_sku               = "2022-Datacenter"
    os_version           = "latest"
    os_disk_storage_type = "Standard_LRS"
    vtpm_enabled         = false
    secure_boot_enabled  = false
  }
  admin_password      = "H3ll0W0rld!"
  resource_group_name = azurerm_resource_group.this.name
  subnet              = azurerm_subnet.this
  severity_group      = "01-first-monday-2000-csu-reboot"

  data_disks = {
    "Data00" = {
      lun                        = 0
      disk_size_gb               = 256
      caching                    = "None"
      create_option              = "Restore"
      source_resource_id         = "/subscriptions/1a126c65-d2c8-4a7f-81ed-f6bcdac6c503/resourceGroups/rg-BAIS-App-qas-01/providers/Microsoft.Compute/disks/vm-CUSTAPP001-datadisk-00"
      storage_account_type       = "Premium_LRS"
      write_accelerator_enabled  = false
      on_demand_bursting_enabled = false
      trusted_launch_enabled     = false
      virtual_machine_id         = "/subscriptions/b48fbace-f1cd-449e-b837-41c6f1a3c96d/resourceGroups/rg-examples_vm_deploy-01/providers/Microsoft.Compute/virtualMachines/vm-CUSTAPP001"
    }
  }

  name_overrides = {
    hostname                      = "CUSTAPP001"
    virtual_machine               = "vm-CUSTAPP001"
    resource_group_name_vm        = "rg-examples_vm_deploy-01"
    resource_group_name_nic       = "rg-examples_vm_deploy-01"
    resource_group_name_data_disk = "rg-examples_vm_deploy-01"
    os_disk                       = "disk-CUSTAPP001-Os"
    nic                           = "nic-CUSTAPP001-10-0-0-0-24"
    data_disks                    = { "Data00" = "disk-CUSTAPP001-Data00" }
  }
}

resource "azurerm_resource_group" "this" {
  name     = "rg-examples_vm_deploy-01"
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

import {
  to = module.virtual_machine.azurerm_windows_virtual_machine.imported[0]
  id = "/subscriptions/<Subscription ID>/resourceGroups/rg-examples_vm_deploy-01/providers/Microsoft.Compute/virtualMachines/vm-CUSTAPP001" # <-- Fill in Resource ID of the existing VM
}

import {
  to = module.virtual_machine.azurerm_network_interface.this
  id = "/subscriptions/<Subscription ID>/resourceGroups/rg-examples_vm_deploy-01/providers/Microsoft.Network/networkInterfaces/nic-CUSTAPP001-10-0-0-0-24" # <-- Fill in Resource ID of the existing NIC
}

import {
  to = module.virtual_machine.azurerm_managed_disk.imported["Data00"]
  id = "/subscriptions/<Subscription ID>/resourceGroups/rg-examples_vm_deploy-01/providers/Microsoft.Compute/disks/disk-CUSTAPP001-Data00" # <-- Fill in Resource ID of the existing Data Disk
}

import {
  to = module.virtual_machine.azurerm_virtual_machine_data_disk_attachment.imported["Data00"]
  id = "/subscriptions/<Subscription ID>/resourceGroups/rg-examples_vm_deploy-01/providers/Microsoft.Compute/virtualMachines/vm-CUSTAPP001/dataDisks/disk-CUSTAPP001-Data00" # <-- Fill in Resource ID of the existing Data Disk Attachment
}

import {
  to = azurerm_virtual_network.this
  id = "/subscriptions/<Subscription ID>/resourceGroups/rg-examples_vm_deploy-01/providers/Microsoft.Network/virtualNetworks/vnet-examples_vm_deploy-01" # <-- Fill in Resource ID of the existing VNet
}

import {
  to = azurerm_subnet.this
  id = "/subscriptions/<Subscription ID>/resourceGroups/rg-examples_vm_deploy-01/providers/Microsoft.Network/virtualNetworks/vnet-examples_vm_deploy-01/subnets/snet-examples_vm_deploy-01" # <-- Fill in Resource ID of the existing Subnet
}

import {
  to = azurerm_resource_group.this
  id = "/subscriptions/<Subscription ID>/resourceGroups/rg-examples_vm_deploy-01" # <-- Fill in Resource ID of the existing Resource Group
}
