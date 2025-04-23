resource "helm_release" "open_telemetry_operator" {
  count = local.aks.enabled && local.telemetry.enabled ? 1 : 0

  name             = "open-telemetry-operator"
  repository       = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart            = "opentelemetry-operator"
  namespace        = "opentelemetry"
  create_namespace = true
  version          = ">= 0.84.2"

  values = [templatefile("${path.module}/values/otel-operator.yaml", {})]

  depends_on = [
    azurerm_kubernetes_cluster.aks,
    helm_release.cert_manager
  ]
}