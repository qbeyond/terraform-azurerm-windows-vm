resource "azurerm_virtual_machine_extension" "dependencyagentwindows" {
  name                       = "DependencyAgentWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.this.id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentWindows"
  type_handler_version       = "9.6"
  auto_upgrade_minor_version = true
}
