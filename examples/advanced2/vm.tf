locals {
  vm_win = {
    ## Exchange server 1 ##
    CUSTMXP02A = {
      subnet              = azurerm_subnet.this
      location            = azurerm_resource_group.this.location
      resource_group_name = azurerm_resource_group.this.name
  
      public_ip_config = {
        enabled           = false
        allocation_method = "Static"
      }

      nic_config = {
        private_ip  = "10.0.0.16"
        dns_servers = local.dns_servers
      }

      size                 = "Standard_B1s"
      os_sku               = "2022-datacenter-g2"
      os_version           = "latest"
      os_disk_caching      = "ReadWrite"
      os_disk_size_gb      = 128
      os_disk_storage_type = "Premium_LRS"
      timezone             = "W. Europe Standard Time"

      availability_set_id       = azurerm_availability_set.this.id
      write_accelerator_enabled = false

      admin_username = "local_admin"
      admin_password = var.CUSTMXP002A_password
  
      severity_group = "01-fourth-tuesday-0200-XCSUFEDTG-reboot"
      update_allowed = true

      tags = {}

      data_disks = {
        "vm-CUSTMXP02A-datadisk-E-01" = {
          lun                       = 1
          caching                   = "ReadWrite"
          disk_size_gb              = 32
          create_option             = "Empty"
          storage_account_type      = "Premium_LRS"
          write_accelerator_enabled = false
        }
        "vm-CUSTMXP02A-datadisk-P-01" = {
          lun                       = 2
          caching                   = "ReadWrite"
          disk_size_gb              = 32
          create_option             = "Empty"
          storage_account_type      = "Premium_LRS"
          write_accelerator_enabled = false
        }
      }

      name_overrides = {
        os_disk    = "vm-CUSTMXP02A_OsDisk_1"
        data_disks = {
          vm-CUSTMXP02A-datadisk-E-01   = "vm-CUSTMXP02A-datadisk-E-01"
          vm-CUSTMXP02A-datadisk-P-01   = "vm-CUSTMXP02A-datadisk-P-01"
        }
      }
    }
    ## END Exchange server 1 ##

    ## Exchange server 2 ##
    CUSTMXP02B = {
      subnet              = azurerm_subnet.this
      location            = azurerm_resource_group.this.location
      resource_group_name = azurerm_resource_group.this.name
  
      public_ip_config = {
        enabled           = false
        allocation_method = "Static"
      }

      nic_config = {
        private_ip  = "10.0.0.17"
        dns_servers = local.dns_servers
      }

      size                 = "Standard_B1s"
      os_sku               = "2022-datacenter-g2"
      os_version           = "latest"
      os_disk_caching      = "ReadWrite"
      os_disk_size_gb      = 128
      os_disk_storage_type = "Premium_LRS"
      timezone             = "W. Europe Standard Time"

      availability_set_id       = azurerm_availability_set.this.id
      write_accelerator_enabled = false

      admin_username = "local_admin"
      admin_password = var.CUSTMXP002B_password

      severity_group = "01-last-friday-0200-XCSUFEDTG-reboot"
      update_allowed = true

      tags = {}

      data_disks = {
        "vm-CUSTMXP02B-datadisk-E-01" = {
          lun                       = 1
          caching                   = "ReadWrite"
          disk_size_gb              = 32
          create_option             = "Empty"
          storage_account_type      = "Premium_LRS"
          write_accelerator_enabled = false
        }
      }

      name_overrides = {
      }
    }
    ## END Exchange server 2 ##
  }
}