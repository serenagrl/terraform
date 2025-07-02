resource "helm_release" "dashboard" {
  count = var.dashboard_enabled ? 1 : 0

  name = "kubernetes-dashboard"

  repository       = "https://kubernetes.github.io/dashboard/"
  chart            = "kubernetes-dashboard"
  namespace        = "dashboard"
  create_namespace = true
  # version          = "7.10"

  values = [templatefile("${path.module}/values/kubernetes-dashboard.yaml", {
              ingress_host = coalesce(var.internal_ingress_host, data.kubernetes_service.internal_ingress_service.status[0].load_balancer[0].ingress[0].hostname)
           })]

  depends_on = [helm_release.ingress_nginx]
}
