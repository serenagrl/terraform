resource "azurerm_subnet" "public" {
  name                 = "${local.project}-public-subnet"
  address_prefixes     = ["${local.subnet_cidrs[0]}"]
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_subnet" "private" {
  name                 = "${local.project}-private-subnet"
  address_prefixes     = ["${local.subnet_cidrs[1]}"]
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}
