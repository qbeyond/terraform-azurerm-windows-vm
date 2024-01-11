provider "azurerm" {
  features {}
}

module "virtual_machine" {
  source = "../.."
  public_ip_config = {
    enabled           = true
    allocation_method = "Static"
  }
  nic_config = {
    private_ip  = "10.0.0.16"
    dns_servers = ["10.0.0.10", "10.0.0.11"]
    nsg         = azurerm_network_security_group.this
  }
  virtual_machine_config = {
    hostname                     = "CUSTAPP007"
    size                         = "Standard_B1s"
    os_sku                       = "2022-datacenter-g2"
    location                     = azurerm_resource_group.this.location
    availability_set_id          = azurerm_availability_set.this.id
    write_accelerator_enabled    = false
    proximity_placement_group_id = azurerm_proximity_placement_group.this.id
    os_version                   = "latest"
    admin_username               = "loc_admin"
    os_disk_caching              = "ReadWrite"
    os_disk_storage_type         = "Standard_LRS"
    os_disk_size_gb              = 128
    os_disk_name                 = "DiskOverride"
    timezone                     = "Azores Standard Time"

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

  log_analytics_agent = azurerm_log_analytics_workspace.this
  additional_network_interface_ids = [azurerm_network_interface.additional_nic_01.id]
  enable_accelerated_networking    = true
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
  name                = local.availability_set_name
  location            = local.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_proximity_placement_group" "this" {
  name                = local.proximity_placement_group_name
  location            = local.location
  resource_group_name = azurerm_resource_group.this.name
  allowed_vm_sizes    = ["Standard_B1s", "Standard_M32ms_v2", "Standard_E16as_v5", "Standard_E8as_v5"]
  
  lifecycle {
      ignore_changes = [tags]
  }
}

resource "azurerm_network_interface" "additional_nic_01" {
  name                          = "nic-vm-${replace(element(azurerm_virtual_network.this.address_space,0), "/[./]/", "-")}-01"
  location                      = local.location
  resource_group_name           = azurerm_resource_group.this.name
  dns_servers                   = []
  enable_accelerated_networking = true

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

resource "azurerm_log_analytics_workspace" "this" {
  name                = local.law_name
  location            = local.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
