resource "azurerm_container_registry" "container_registry" {
  count = local.aks.acr_enabled ? 1 : 0

  name                = "Consolsys01"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  sku                 = "Basic"
  admin_enabled       = true
  
}

resource "azurerm_role_assignment" "aks_container_registry_integration" {
  count = local.aks.acr_enabled ? 1 : 0

  principal_id                     = azurerm_kubernetes_cluster.aks[0].kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.container_registry[0].id
  skip_service_principal_aad_check = true
}

output "acr_username" {
  value = try(azurerm_container_registry.container_registry[0].admin_username, null)
  depends_on = [ azurerm_container_registry.container_registry ]
}

output "acr_password" {
  value     = try(azurerm_container_registry.container_registry[0].admin_password, null)
  sensitive = true
  depends_on = [ azurerm_container_registry.container_registry ]
}