resource "random_password" "sql" {
  count = local.mssql.enabled && (local.mssql.password == null || local.mssql.password == "") && upper(local.mssql.type) == "DATABASE" ? 1 : 0

  length  = 16
  special = true
}

resource "azurerm_mssql_server" "sql" {
  count = local.mssql.enabled && upper(local.mssql.type) == "DATABASE" ? 1 : 0

  name                          = local.mssql.server_name
  resource_group_name           = azurerm_resource_group.aks.name
  location                      = azurerm_resource_group.aks.location
  version                       = local.mssql.sql_database.version
  administrator_login           = local.mssql.username
  administrator_login_password  = coalesce(local.mssql.password, try(random_password.sql[0].result, ""))
  public_network_access_enabled = local.mssql.public_network
}

resource "azurerm_mssql_database" "sql" {
  count = local.mssql.enabled && upper(local.mssql.type) == "DATABASE" ? length(local.mssql.databases) : 0

  name                 = local.mssql.databases[count.index]
  server_id            = azurerm_mssql_server.sql[0].id
  license_type         = local.mssql.license_included ? "LicenseIncluded" : "BasePrice"
  max_size_gb          = local.mssql.sql_database.max_size_gb
  sku_name             = local.mssql.sql_database.sku
  enclave_type         = local.mssql.sql_database.enclave_type != "" ? local.mssql.sql_database.enclave_type : null
  storage_account_type = local.mssql.sql_database.storage_account_type
}

resource "azurerm_mssql_firewall_rule" "sql_client_access" {
  count = local.mssql.enabled && upper(local.mssql.type) == "DATABASE" && local.mssql.public_network ? 1 : 0

  name             = "sql-client-access"
  server_id        = azurerm_mssql_server.sql[0].id
  start_ip_address = coalesce(local.local_gateway_ip, try(trimspace(data.curl.get_public_ip[0].response), ""))
  end_ip_address   = coalesce(local.local_gateway_ip, try(trimspace(data.curl.get_public_ip[0].response), ""))
}

# Allow Azure services and resources to access through public network.
resource "azurerm_mssql_firewall_rule" "sql_azure_access" {
  count = local.mssql.enabled && upper(local.mssql.type) == "DATABASE" && local.mssql.public_network ? 1 : 0

  name             = "sql-azure-access"
  server_id        = azurerm_mssql_server.sql[0].id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_private_dns_zone" "sql" {
  count = local.mssql.enabled && upper(local.mssql.type) == "DATABASE" && !local.mssql.public_network ? 1 : 0

  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.aks.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql" {
  count = local.mssql.enabled && upper(local.mssql.type) == "DATABASE" && !local.mssql.public_network ? 1 : 0

  name                  = "${local.project}-sql-network-link"
  private_dns_zone_name = azurerm_private_dns_zone.sql[0].name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = azurerm_resource_group.aks.name

  depends_on = [ azurerm_mssql_server.sql ]
}

resource "azurerm_private_endpoint" "sql" {
  count = local.mssql.enabled && upper(local.mssql.type) == "DATABASE" && !local.mssql.public_network ? 1 : 0

  name                          = "${local.project}-sql-private-endpoint"
  location                      = azurerm_resource_group.aks.location
  resource_group_name           = azurerm_resource_group.aks.name
  subnet_id                     = azurerm_subnet.services.id
  custom_network_interface_name = "${local.project}-sql-interface"

  private_service_connection {
    name                           = "sql-connection"
    private_connection_resource_id = azurerm_mssql_server.sql[0].id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }

  private_dns_zone_group {
    name                 = "sql-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.sql[0].id]
  }
}