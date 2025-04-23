resource "azurerm_public_ip" "tunnel_ips" {
  count = local.vpn.enabled ? 2 : 0

  name                = "${local.project}-tunnel-ip${count.index + 1}"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [1,2,3]
}

resource "azurerm_subnet" "vpn" {
  count = local.vpn.enabled ? 1 : 0

  name                 = "GatewaySubnet" # Cannot Change
  address_prefixes     = ["${local.vpn.subnet_cidr}"]
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  depends_on = [ azurerm_virtual_network.vnet ]

}

resource "azurerm_virtual_network_gateway" "azure" {
  count = local.vpn.enabled ? 1 : 0

  name                = "${local.project}-vnet-gateway"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = true
  enable_bgp    = false
  sku           = local.vpn.vnet_gateway_sku

  ip_configuration {
    name                 = "vnet-gateway-tunnel1"
    public_ip_address_id = azurerm_public_ip.tunnel_ips[0].id
    subnet_id            = azurerm_subnet.vpn[0].id
  }

  ip_configuration {
    name                 = "vnet-gateway-tunnel2"
    public_ip_address_id = azurerm_public_ip.tunnel_ips[1].id
    subnet_id            = azurerm_subnet.vpn[0].id
  }

  depends_on = [
    azurerm_public_ip.tunnel_ips,
    azurerm_subnet.vpn
  ]

}