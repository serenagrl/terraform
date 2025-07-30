resource "helm_release" "nginx-internal" {
  name       = "nginx-internal"
  chart      = "./charts/create-nginx-internal"

  depends_on = [azurerm_kubernetes_cluster.aks]
}