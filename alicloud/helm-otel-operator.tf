resource "helm_release" "open_telemetry_operator" {
  count = local.ack.enabled && local.ack.telemetry_enabled ? 1 : 0

  name             = "open-telemetry-operator"
  repository       = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart            = "opentelemetry-operator"
  namespace        = "opentelemetry"
  create_namespace = true
  # version          = "0.84.2"
  wait             = true
  timeout          = 900

  values = [templatefile("${path.module}/values/otel-operator.yaml", {})]

  depends_on = [
    alicloud_cs_managed_kubernetes.ack,
    alicloud_cs_kubernetes_node_pool.default,
    helm_release.cert_manager,
    data.alicloud_cs_cluster_credential.ack
  ]
}