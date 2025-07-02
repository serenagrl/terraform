resource "helm_release" "argocd" {
  count = local.ack.enabled && local.ack.argocd_enabled ? 1 : 0

  name             = "argo"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  # version          = "7.8"
  values           = [templatefile("${path.module}/values/argocd.yaml", {})]
  wait             = true
  timeout          = 1200

  depends_on = [
    alicloud_cs_managed_kubernetes.ack,
    alicloud_cs_kubernetes_node_pool.default,
    data.alicloud_cs_cluster_credential.ack
  ]
}
