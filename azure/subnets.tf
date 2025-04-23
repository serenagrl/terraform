resource "azurerm_subnet" "aks" {
  name                            = "${local.project}-aks-subnet"
  address_prefixes                = ["${local.vnet.subnet_cidrs.aks}"]
  resource_group_name             = azurerm_resource_group.aks.name
  virtual_network_name            = azurerm_virtual_network.vnet.name
  default_outbound_access_enabled = "false"

  depends_on = [ azurerm_virtual_network.vnet ]
}

resource "azurerm_subnet" "services" {
  name                            = "${local.project}-services-subnet"
  address_prefixes                = ["${local.vnet.subnet_cidrs.services}"]
  resource_group_name             = azurerm_resource_group.aks.name
  virtual_network_name            = azurerm_virtual_network.vnet.name
  default_outbound_access_enabled = "false"

  depends_on = [ azurerm_virtual_network.vnet ]
}