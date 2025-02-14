resource "azurerm_resource_group" "rg" {
  name     = "${local.project}-cluster"
  location = local.region
}