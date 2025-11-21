resource "helm_release" "nginx-internal" {
  count = local.aks.enabled ? 1 : 0

  name  = "nginx-internal"
  chart = "./charts/create-nginx-internal"

  depends_on = [azurerm_kubernetes_cluster.aks]
}