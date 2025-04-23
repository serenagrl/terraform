# Enable preview features at subscription level. Only need to run once.
# source: https://learn.microsoft.com/en-us/azure/aks/node-autoprovision?tabs=azure-cli#register-the-nodeautoprovisioningpreview-feature-flag
#
# az feature register --namespace "Microsoft.ContainerService" --name "NodeAutoProvisioningPreview"
# az feature show --namespace "Microsoft.ContainerService" --name "NodeAutoProvisioningPreview"
# az provider register --namespace Microsoft.ContainerService

resource "azurerm_role_assignment" "karpenter_network_role" {
  count = local.aks.enabled && local.aks.karpenter_enabled ? 1 : 0

  scope                = azurerm_virtual_network.vnet.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks[0].identity[0].principal_id
}

resource "azapi_update_resource" "nap" {
  count = local.aks.enabled && local.aks.karpenter_enabled ? 1 : 0

  type                    = "Microsoft.ContainerService/managedClusters@2025-02-02-preview"
  resource_id             = azurerm_kubernetes_cluster.aks[0].id
  ignore_missing_property = true
  body = {
    properties = {
      nodeProvisioningProfile = {
        mode = "Auto"
      }
    }
  }
}