resource "azurerm_virtual_network_gateway_connection" "site_to_site_vpn" {
  count = local.vpn.enabled ? 1 : 0

  name                = "${local.project}-vpn-local"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.azure[0].id
  local_network_gateway_id   = azurerm_local_network_gateway.on_premise[0].id
  connection_protocol        = "IKEv2"
  shared_key                 = local.vpn.shared_key

  depends_on = [
    azurerm_local_network_gateway.on_premise,
    azurerm_virtual_network_gateway.azure
  ]
}