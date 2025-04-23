resource "azurerm_public_ip" "nat" {
  name                = "${local.project}-aks-subnet-nat-ip"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "nat" {
  name                = "${local.project}-aks-subnet-nat-gw"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "nat_ip_assoc" {
  nat_gateway_id       = azurerm_nat_gateway.nat.id
  public_ip_address_id = azurerm_public_ip.nat.id

  depends_on = [
    azurerm_nat_gateway.nat,
    azurerm_public_ip.nat
  ]
}

resource "azurerm_subnet_nat_gateway_association" "aks_subnet_nat_assoc" {
  subnet_id      = azurerm_subnet.aks.id
  nat_gateway_id = azurerm_nat_gateway.nat.id

  depends_on = [
    azurerm_subnet.aks,
    azurerm_nat_gateway.nat
  ]
}

