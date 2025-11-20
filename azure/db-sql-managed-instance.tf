resource "azurerm_subnet" "sql" {
  count = local.mssql.enabled && upper(local.mssql.type) == "MANAGED_INSTANCE" ? 1 : 0

  name                            = "${local.project}-mssql-database-subnet"
  address_prefixes                = ["${local.mssql.subnet_cidr}"]
  resource_group_name             = azurerm_resource_group.aks.name
  virtual_network_name            = azurerm_virtual_network.vnet.name

  delegation {
    name = "mssql"

    service_delegation {
      name    = "Microsoft.Sql/managedInstances"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action", "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"]
    }
  }

  depends_on = [ azurerm_virtual_network.vnet ]
}

resource "azurerm_route_table" "sql" {
  count = local.mssql.enabled && upper(local.mssql.type) == "MANAGED_INSTANCE" ? 1 : 0

  name                          = "${local.project}-mssql-managed-instance-route-table"
  location                      = azurerm_resource_group.aks.location
  resource_group_name           = azurerm_resource_group.aks.name

  depends_on = [
    azurerm_subnet.sql,
  ]
}

resource "azurerm_subnet_route_table_association" "sql" {
  count = local.mssql.enabled && upper(local.mssql.type) == "MANAGED_INSTANCE" ? 1 : 0

  subnet_id      = azurerm_subnet.sql[0].id
  route_table_id = azurerm_route_table.sql[0].id
}

resource "azurerm_network_security_group" "sql" {
  count = local.mssql.enabled && upper(local.mssql.type) == "MANAGED_INSTANCE" ? 1 : 0

  name                = "${local.project}-mssql-security-group"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
}

resource "azurerm_subnet_network_security_group_association" "sql" {
  count = local.mssql.enabled && upper(local.mssql.type) == "MANAGED_INSTANCE" ? 1 : 0

  subnet_id                 = azurerm_subnet.sql[0].id
  network_security_group_id = azurerm_network_security_group.sql[0].id
}

resource "azurerm_network_security_rule" "sql" {
  count = local.mssql.enabled && upper(local.mssql.type) == "MANAGED_INSTANCE" ? 1 : 0

  name                        = "allow_management_inbound"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = local.mssql.sql_managed_instance.allow_inbound_port
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.aks.name
  network_security_group_name = azurerm_network_security_group.sql[0].name
}

resource "random_password" "sql_managed_instance" {
  count = local.mssql.enabled && (try(local.mssql.password, "") != "") && upper(local.mssql.type) == "MANAGED_INSTANCE" ? 1 : 0

  length  = 16
  special = true
}

resource "azurerm_mssql_managed_instance" "sql" {
  count = local.mssql.enabled && upper(local.mssql.type) == "MANAGED_INSTANCE" ? 1 : 0

  name                = local.mssql.server_name
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location

  license_type       = local.mssql.license_included ? "LicenseIncluded" : "BasePrice"
  sku_name           = local.mssql.sql_managed_instance.sku
  storage_size_in_gb = local.mssql.sql_managed_instance.storage_size_in_gb
  subnet_id          = azurerm_subnet.sql[0].id
  vcores             = local.mssql.sql_managed_instance.vcore

  storage_account_type   = local.mssql.sql_managed_instance.storage_account_type
  zone_redundant_enabled = local.mssql.sql_managed_instance.zone_redundant_enabled

  administrator_login          = local.mssql.username
  administrator_login_password = coalesce(local.mssql.password, random_password.sql_managed_instance[0].result)

  depends_on = [
    azurerm_subnet_network_security_group_association.sql,
    azurerm_subnet_route_table_association.sql
  ]
}

resource "azurerm_mssql_managed_database" "sql" {
  count = local.mssql.enabled && upper(local.mssql.type) == "MANAGED_INSTANCE" ? length(local.mssql.databases) : 0

  name                = local.mssql.databases[count.index]
  managed_instance_id = azurerm_mssql_managed_instance.sql[0].id
}