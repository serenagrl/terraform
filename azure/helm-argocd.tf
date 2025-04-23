resource "helm_release" "argocd" {
  count = local.aks.enabled && local.aks.argocd_enabled ? 1 : 0

  name             = "argo"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = ">= 7.8"
  values           = [templatefile("${path.module}/values/argocd.yaml", {})]

  depends_on = [
    azurerm_kubernetes_cluster.aks,
    helm_release.nginx-internal
  ]
}
