locals {
  public_ip = {
    name = coalesce(var.name_overrides.public_ip, "pip-vm-${var.virtual_machine_config.hostname}") # change to naming convention= 
  }

  subnet_prefix = (var.subnet.address_prefixes == null
    ? regex(".*subnets/snet-([0-9-]+)-.*$", var.subnet.id)[0] # Parse from subnet id if not provided
    : replace(var.subnet.address_prefixes[0], "/[./]/", "-")  # Replace '.' and '/' with '-' from prefix
  )

  nic = {
    name           = coalesce(var.name_overrides.nic, "nic-${var.virtual_machine_config.hostname}-${local.subnet_prefix}")
    ip_config_name = coalesce(var.name_overrides.nic_ip_config, "internal")
  }

  virtual_machine = {
    name = coalesce(var.name_overrides.virtual_machine, "vm-${var.virtual_machine_config.hostname}")
    tags = merge(var.tags, { "Severity Group Monthly" = var.severity_group }, { "Update allowed" = local.update_allowed })
  }
  os_disk_name   = coalesce(var.name_overrides.os_disk, "disk-${var.virtual_machine_config.hostname}-Os")
  update_allowed = var.update_allowed ? "yes" : "no"


}
