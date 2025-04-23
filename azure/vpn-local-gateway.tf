# Get current public IP address for setting up VPN.
data "curl" "get_public_ip" {
  count = local.vpn.enabled ? 1 : 0

  http_method = "GET"
  uri         = "https://ipv4.icanhazip.com"
}

resource "azurerm_local_network_gateway" "on_premise" {
  count = local.vpn.enabled ? 1 : 0

  name                = "${local.project}-local-gateway"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  gateway_address     = coalesce(local.vpn.local_gateway_ip, trimspace(data.curl.get_public_ip[0].response))
  address_space       = local.vpn.local_address_space
}