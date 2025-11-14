resource "helm_release" "configure_karpenter" {
  count = local.aks.enabled && local.aks.karpenter_enabled ? 1 : 0

  name  = "configure-karpenter"
  chart = "./charts/configure-karpenter"

  depends_on = [
    azurerm_kubernetes_cluster.aks,
    azapi_update_resource.nap
  ]
}