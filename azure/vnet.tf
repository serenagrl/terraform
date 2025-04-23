resource "azurerm_virtual_network" "vnet" {
  name                = "${local.project}-vnet"
  address_space       = ["${local.vnet.cidr}"]
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name

  depends_on = [ azurerm_resource_group.aks ]
}