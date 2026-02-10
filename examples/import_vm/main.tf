# How to use this example:
# 1. Create a Windows VM in Azure with the Basic example.
# 2. Fill in the subscription_id in the provider block of this example and adjust the import blocks to match the existing Resources.
# 3. Run this example and try to import the existing VM into the state file of this example.
# 4. If all resources get imported successfully, the Module works as intended.
# (There are two error build in to test the correction of the name_overrides. The hostname and RG name)
provider "azurerm" {
  subscription_id = "" # <-- Fill in Subscription ID
  features {}
}

module "virtual_machine" {
  source = "../.."
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

  name_overrides = {
    hostname = "CUSTAPP001"
    virtual_machine = "vm-CUSTAPP001"
    resource_group_name = "rg-examples_vm_deploy-01"
    os_disk = "disk-CUSTAPP001-Os"
    nic = "nic-CUSTAPP001-10-0-0-0-24"
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