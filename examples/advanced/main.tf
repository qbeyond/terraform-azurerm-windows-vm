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
    hostname                     = "CUSTAPP007"
    location                     = azurerm_resource_group.this.location
    size                         = "Standard_B1s"
    os_sku                       = "2022-datacenter-g2"
    os_version                   = "latest"
    os_disk_name                 = "DiskOverride"
    os_disk_size_gb              = 128
    os_disk_caching              = "ReadWrite"
    os_disk_storage_type         = "Standard_LRS"
    os_disk_write_accelerator_enabled = false
    availability_set_id          = azurerm_availability_set.this.id
    proximity_placement_group_id = azurerm_proximity_placement_group.this.id

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
