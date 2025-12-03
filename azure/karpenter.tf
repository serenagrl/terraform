resource "azurerm_role_assignment" "karpenter_network_role" {
  count = local.aks.enabled && local.aks.karpenter_enabled ? 1 : 0

  scope                = azurerm_virtual_network.vnet.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks[0].identity[0].principal_id

  depends_on = [ 
    azurerm_kubernetes_cluster.aks
  ]
}

resource "azapi_update_resource" "nap" {
  count = local.aks.enabled && local.aks.karpenter_enabled ? 1 : 0

  type                    = "Microsoft.ContainerService/managedClusters@2025-09-01"
  resource_id             = azurerm_kubernetes_cluster.aks[0].id
  ignore_missing_property = true
  body = {
    properties = {
      nodeProvisioningProfile = {
        mode = "Auto"
      }
    }
  }

  depends_on = [ 
    azurerm_kubernetes_cluster.aks,
    azurerm_role_assignment.karpenter_network_role
  ]
}