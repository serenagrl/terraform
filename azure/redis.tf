resource "azurerm_redis_cache" "redis" {
  count = local.redis.enabled ? 1 : 0

  name                          = local.redis.name
  location                      = azurerm_resource_group.aks.location
  resource_group_name           = azurerm_resource_group.aks.name
  capacity                      = local.redis.capacity
  family                        = upper(local.redis.sku) == "PREMIUM" ? "P" : "C"
  sku_name                      = local.redis.sku
  non_ssl_port_enabled          = false
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false
  replicas_per_master           = upper(local.redis.sku) == "PREMIUM" && local.redis.shards != null ? local.redis.replicas_per_master : null
  shard_count                   = upper(local.redis.sku) == "PREMIUM" ? local.redis.shards : null
}

resource "azurerm_private_dns_zone" "redis" {
  count = local.redis.enabled ? 1 : 0

  name                = "privatelink.redis.cache.windows.net" # Cannot be changed.
  resource_group_name = azurerm_resource_group.aks.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "redis" {
  count = local.redis.enabled ? 1 : 0

  name                  = "${local.project}-redis-network-link"
  private_dns_zone_name = azurerm_private_dns_zone.redis[0].name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = azurerm_resource_group.aks.name
  depends_on            = [azurerm_subnet.aks]
}

resource "azurerm_private_endpoint" "redis" {
  count = local.redis.enabled ? 1 : 0

  name                = "${local.project}-redis-private-endpoint"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  subnet_id           = azurerm_subnet.services.id
  custom_network_interface_name = "redis-network-interface"

  private_service_connection {
    name                           = "redis-connection"
    private_connection_resource_id = azurerm_redis_cache.redis[0].id
    is_manual_connection           = false
    subresource_names              = ["redisCache"]
  }

  private_dns_zone_group {
    name                 = "redis-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.redis[0].id]
  }
}