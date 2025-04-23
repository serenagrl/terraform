resource "azurerm_resource_group" "aks" {
  name     = "${local.project}-cluster"
  location = local.region
}