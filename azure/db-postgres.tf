
resource "azurerm_subnet" "database" {
  count = local.postgres.enabled ? 1 : 0

  name                            = "${local.project}-database-subnet"
  address_prefixes                = ["${local.vnet.subnet_cidrs.database}"]
  resource_group_name             = azurerm_resource_group.aks.name
  virtual_network_name            = azurerm_virtual_network.vnet.name
  default_outbound_access_enabled = "false"

  delegation {
     name = "postgresql"

     service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
     }
  }

  depends_on = [ azurerm_virtual_network.vnet ]
}

resource "azurerm_private_dns_zone" "private_dns_zone" {
  count = local.postgres.enabled ? 1 : 0

  name                = "${local.postgres.server_name}.private.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.aks.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "network_link" {
  count = local.postgres.enabled ? 1 : 0

  name                  = "${local.project}-network-link"
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone[0].name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = azurerm_resource_group.aks.name
  depends_on            = [azurerm_subnet.database]
}

resource "random_password" "postgres_password" {
  count = local.postgres.enabled && (try(local.postgres.password, "") != "") ? 1 : 0

  length  = 16
  special = false
}

resource "azurerm_postgresql_flexible_server" "postgres" {
  count = local.postgres.enabled ? 1 : 0

  name                          = local.postgres.server_name
  resource_group_name           = azurerm_resource_group.aks.name
  location                      = azurerm_resource_group.aks.location
  version                       = local.postgres.version
  delegated_subnet_id           = azurerm_subnet.database[0].id
  private_dns_zone_id           = azurerm_private_dns_zone.private_dns_zone[0].id
  public_network_access_enabled = false
  administrator_login           = local.postgres.username
  administrator_password        = coalesce(local.postgres.password, random_password.postgres_password[0].result)
  zone                          = "1"

  storage_mb   = 32768
  storage_tier = "P4"

  sku_name   = local.postgres.sku
  depends_on = [azurerm_private_dns_zone_virtual_network_link.network_link]

}

resource "azurerm_postgresql_flexible_server_configuration" "postgres" {
  count = local.postgres.enabled && try(local.postgres.extensions, "") != "" ? 1 : 0

  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.postgres[0].id
  value     = coalesce(local.postgres.extensions, " ") # Empty space to short circuit the validation.

  depends_on = [ azurerm_postgresql_flexible_server.postgres ]
}

output "postgres_password" {
  sensitive = true
  value = try(azurerm_postgresql_flexible_server.postgres[0].administrator_password, "null")
  description = "The initial password for postgres when it was created."

  depends_on = [ azurerm_postgresql_flexible_server.postgres ]
}