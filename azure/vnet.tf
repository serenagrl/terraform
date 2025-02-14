resource "azurerm_virtual_network" "vnet" {
  name                = "${local.project}-vnet"
  address_space       = ["${local.vnet_cidr}"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

}