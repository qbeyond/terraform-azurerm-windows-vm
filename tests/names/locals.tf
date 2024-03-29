locals {
  location             = "West Europe"
  resource_group_name  = "rg-examples_vm_deploy-01"
  virtual_network_name = "vnet-examples_vm_deploy-01"
  subnet_name          = "snet-examples_vm_deploy-01"
  hostname             = "CUSTAPP001"
  disk_name_os         = "disk-${local.hostname}-Os"
  data_disk_names = {
    test1 = "disk-${local.hostname}-test1"
  }
}
