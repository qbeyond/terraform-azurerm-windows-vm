module "virtual_machine" {
    source = "git::https://github.com/qbeyond/terraform-azurerm-domain-controller"
    nic_config = {
        subnet = azurerm_subnet.snet
    }
    virtual_machine_config {
        hostname = "CUSTAPP001"
        admin_username = "local_admin"
        size = "Standard_D2_v5"
        os_sku = "2022-Datacenter"
        os_version = "latest"
    }
    admin_password = "password123"
    resource_group = azurerm_resource_group.vm 
}