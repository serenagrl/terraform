resource "azurerm_subnet" "dns_resolver" {
  count = local.vpn.enabled && local.vpn.dns_resolver_enabled ? 1 : 0

  name                 = "${local.project}-dns-resolver-subnet"
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["${local.vpn.dns_resolver_cidr}"]

  delegation {
    name = "dns-resolvers"
    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      name    = "Microsoft.Network/dnsResolvers"
    }
  }

  depends_on = [ azurerm_virtual_network.vnet ]
}

resource "azurerm_private_dns_resolver" "dns_resolver" {
  count = local.vpn.enabled && local.vpn.dns_resolver_enabled ? 1 : 0

  name                = "${local.project}-dns-resolver"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  virtual_network_id  = azurerm_virtual_network.vnet.id

  depends_on = [
    azurerm_virtual_network.vnet,
    azurerm_virtual_network_gateway.azure
  ]
}

resource "azurerm_private_dns_resolver_inbound_endpoint" "dns_inbound_endpoint" {
  count = local.vpn.enabled && local.vpn.dns_resolver_enabled ? 1 : 0

  name                    = "${local.project}-dns-inbound-endpoint"
  private_dns_resolver_id = azurerm_private_dns_resolver.dns_resolver[0].id
  location                = azurerm_private_dns_resolver.dns_resolver[0].location

  ip_configurations {
    private_ip_allocation_method = "Dynamic"
    subnet_id                    = azurerm_subnet.dns_resolver[0].id
  }

  depends_on = [ azurerm_private_dns_resolver.dns_resolver ]
}