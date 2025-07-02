resource "helm_release" "keda" {
  count = var.keda_enabled ? 1 : 0

  name = "keda"

  repository       = "https://kedacore.github.io/charts"
  chart            = "keda"
  namespace        = "keda"
  create_namespace = true
  # version          = "2.16"

  depends_on = [helm_release.ingress_nginx]
}

resource "helm_release" "keda-http" {
  count = var.keda_http_enabled ? 1 : 0
  name = "keda-http"

  repository       = "https://kedacore.github.io/charts"
  chart            = "keda-add-ons-http"
  namespace        = "keda"
  create_namespace = true
  version          = ">= 0.9"

  set = [
    {
      name  = "interceptor.replicas.waitTimeout"
      value = "180s"
    },
    {
      name  = "interceptor.responseHeaderTimeout"
      value = "180s"
    }
  ]

  depends_on = [helm_release.keda]
}

