provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "cryptouser" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = data.azurerm_client_config.current.object_id
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

resource "azurerm_key_vault" "this" {
  name                        = local.key_vault_name
  resource_group_name         = azurerm_resource_group.this.name
  location                    = azurerm_resource_group.this.location
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  enable_rbac_authorization   = true
  purge_protection_enabled    = false
  enabled_for_disk_encryption = true

  lifecycle {
    create_before_destroy = true
  }
}


resource "azurerm_key_vault_key" "this" {
  name         = local.key_name
  key_vault_id = azurerm_key_vault.this.id
  key_type     = "RSA"
  key_size     = 4096
  key_opts     = ["encrypt", "decrypt", "sign", "verify", "wrapKey", "unwrapKey"]

  depends_on = [azurerm_role_assignment.cryptouser]
}

module "virtual_machine" {
  source = "../.."

  virtual_machine_config = {
    hostname             = "CUSTAPP001"
    location             = local.location
    admin_username       = "local_admin"
    size                 = "Standard_B1s"
    os_sku               = "2022-Datacenter"
    os_version           = "latest"
    os_disk_storage_type = "Standard_LRS"
  }

  admin_password      = "H3ll0W0rld!"
  resource_group_name = azurerm_resource_group.this.name
  subnet              = azurerm_subnet.this
  severity_group      = "01-first-monday-2000-csu-reboot"

  disk_encryption = {
    settings = {
      EncryptionOperation    = "EnableEncryption"
      KeyEncryptionAlgorithm = "RSA-OAEP-256"
      KeyVaultURL            = azurerm_key_vault.this.vault_uri
      KeyVaultResourceId     = azurerm_key_vault.this.id
      KekVaultResourceId     = azurerm_key_vault.this.id
      KeyEncryptionKeyURL    = "${azurerm_key_vault.this.vault_uri}keys/${azurerm_key_vault_key.this.name}/${azurerm_key_vault_key.this.version}"
      VolumeType             = "All"
    }
  }
  depends_on = [
    azurerm_role_assignment.cryptouser
  ]
}

