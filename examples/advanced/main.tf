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
    hostname             = "CUSTAPP007"
    size                 = "Standard_B1s"
    os_sku               = "2022-datacenter-g2"
    location             = azurerm_resource_group.this.location
    availability_set_id  = azurerm_availability_set.this.id
    os_version           = "latest"
    admin_username       = "loc_admin"
    os_disk_caching      = "ReadWrite"
    os_disk_storage_type = "Standard_LRS"
    os_disk_size_gb      = 128
    os_disk_name         = "DiskOverride"
    timezone             = "Azores Standard Time"

    tags = {
      "Environment" = "prd"
    }
    write_accelerator_enabled = false
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

  name_overrides = {
    nic             = local.nic
    nic_ip_config   = local.nic_ip_config
    public_ip       = local.public_ip
    virtual_machine = local.virtual_machine
    data_disks = {
      "${local.managed_disk_name}" = "Override"
    }
  }
  severity_group = "01-first-monday-2000-csu-reboot"
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
