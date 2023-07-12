resource "azurerm_virtual_machine_extension" "microsoftmonitoringagent" {
  count                      = var.law_config != null ? 1 : 0
  name                       = "MicrosoftMonitoringAgent"
  virtual_machine_id         = azurerm_windows_virtual_machine.this.id
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "MicrosoftMonitoringAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
       "workspaceId" : "${var.law_config.workspace_id}"
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
       "workspaceKey" : "${var.law_config.shared_key}"
    }
PROTECTED_SETTINGS

}
