locals {
  karpenter_tag = local.ack.enabled && upper(local.ack.autoscaler_type) == "KARPENTER" ? { "karpenter.sh/discovery": "${local.project}-cluster" } : {}
}

resource "helm_release" "karpenter" {
  count = local.ack.enabled && upper(local.ack.autoscaler_type) == "KARPENTER" ? 1 : 0

  name             = "karpenter"
  repository       = "https://cloudpilot-ai.github.io/karpenter-provider-alibabacloud"
  chart            = "karpenter"
  namespace        = "karpenter-system"
  version          = ">= 0.2.0"
  create_namespace = true
  wait             = true

  values = [templatefile("${path.module}/values/karpenter.yaml", {
    accessKey = local.access_key
    keySecret = local.secret_key
    region    = local.region
    clusterID = alicloud_cs_managed_kubernetes.ack[0].id
  })]

  depends_on = [
    alicloud_cs_managed_kubernetes.ack,
    alicloud_cs_kubernetes_node_pool.default
  ]
}

resource "helm_release" "configure_karpenter" {
  count = local.ack.enabled && upper(local.ack.autoscaler_type) == "KARPENTER" ? 1 : 0

  name  = "configure-karpenter"
  chart = "./charts/configure-karpenter"

  set {
    name  = "clusterName"
    value = alicloud_cs_managed_kubernetes.ack[0].name
  }

  depends_on = [
    helm_release.karpenter,
    alicloud_cs_managed_kubernetes.ack,
    alicloud_cs_kubernetes_node_pool.default
  ]
}