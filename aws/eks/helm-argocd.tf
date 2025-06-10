resource "helm_release" "argocd" {
  count = var.argocd_enabled ? 1 : 0

  name = "argo"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = ">= 8.0"

  values = [templatefile("${path.module}/values/argocd.yaml", {
              ingress_host = coalesce(var.internal_ingress_host, data.kubernetes_service.internal_ingress_service.status[0].load_balancer[0].ingress[0].hostname)
           })]

  depends_on = [helm_release.ingress_nginx]
}
