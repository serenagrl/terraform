resource "azurerm_storage_account" "aks" {
  count = local.aks.enabled ? 1 : 0

  name                          = local.aks.storage.account_name
  resource_group_name           = azurerm_kubernetes_cluster.aks[0].node_resource_group
  location                      = azurerm_resource_group.aks.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  public_network_access_enabled = false

  depends_on = [ azurerm_kubernetes_cluster.aks ]
}

#region File CSI
resource "azurerm_private_dns_zone" "file_csi" {
  count = local.aks.enabled ? 1 : 0

  name                = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.aks.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "file_csi" {
  count = local.aks.enabled ? 1 : 0

  name                  = "${local.project}-file-csi-network-link"
  private_dns_zone_name = azurerm_private_dns_zone.file_csi[0].name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = azurerm_resource_group.aks.name

  depends_on = [ azurerm_kubernetes_cluster.aks ]
}

resource "azurerm_private_endpoint" "file_csi" {
  count = local.aks.enabled ? 1 : 0

  name                          = "${local.project}-file-csi-private-endpoint"
  location                      = azurerm_resource_group.aks.location
  resource_group_name           = azurerm_resource_group.aks.name
  subnet_id                     = azurerm_subnet.services.id
  custom_network_interface_name = "${local.project}-file-csi-interface"

  private_service_connection {
    name                           = "file-csi-connection"
    private_connection_resource_id = azurerm_storage_account.aks[0].id
    is_manual_connection           = false
    subresource_names              = ["file"]
  }

  private_dns_zone_group {
    name                 = "file-csi-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.file_csi[0].id]
  }
}
#endregion

#region Blob Storage
resource "azurerm_private_dns_zone" "blob" {
  count = local.aks.enabled && local.aks.storage.create_blob_storage ? 1 : 0

  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.aks.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  count = local.aks.enabled && local.aks.storage.create_blob_storage ? 1 : 0

  name                  = "${local.project}-blob-csi-network-link"
  private_dns_zone_name = azurerm_private_dns_zone.blob[0].name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = azurerm_resource_group.aks.name

  depends_on = [ azurerm_kubernetes_cluster.aks ]
}

resource "azurerm_private_endpoint" "blob" {
  count = local.aks.enabled && local.aks.storage.create_blob_storage ? 1 : 0

  name                          = "${local.project}-blob-csi-private-endpoint"
  location                      = azurerm_resource_group.aks.location
  resource_group_name           = azurerm_resource_group.aks.name
  subnet_id                     = azurerm_subnet.services.id
  custom_network_interface_name = "${local.project}-blob-csi-interface"

  private_service_connection {
    name                           = "blob-csi-connection"
    private_connection_resource_id = azurerm_storage_account.aks[0].id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "blob-csi-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob[0].id]
  }
}

resource "azurerm_storage_container" "blob" {
  count = local.aks.enabled && local.aks.storage.create_blob_storage ? 1 : 0

  name                  = local.aks.storage.blob_container_name
  storage_account_id    = azurerm_storage_account.aks[0].id
  container_access_type = "private"
}
#endregion