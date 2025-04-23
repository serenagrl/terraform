resource "helm_release" "cert_manager" {
  name = "cert-manager"

  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = ">= 1.16"

  set {
    name  = "crds.enabled"
    value = "true"
  }

  set {
    name  = "crds.keep"
    value = "false"
  }

  depends_on = [azurerm_kubernetes_cluster.aks]

}