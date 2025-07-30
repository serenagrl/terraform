# Note: Source is from https://github.com/AliyunContainerService/ack-secret-manager

resource "helm_release" "secrets_manager" {
  count = local.kms.enabled && local.ack.enabled && local.ack.secret_manager_enabled ? 1 : 0

    name      = "secret-manager"
    chart     = "https://aliacs-k8s-ap-southeast-1.oss-ap-southeast-1.aliyuncs.com/app/charts-incubator/ack-secret-manager-0.5.12.tgz"
    namespace = "kube-system"
    wait      = true

  values = [templatefile("${path.module}/values/ack-secret-manager.yaml", {
    region    = local.region
  })]

  depends_on = [
    alicloud_cs_managed_kubernetes.ack,
    alicloud_cs_kubernetes_node_pool.default,
    data.alicloud_cs_cluster_credential.ack,
    alicloud_kms_instance.kms,
  ]
}

data "alicloud_ram_policy_document" "secrets_manager" {
  count = local.kms.enabled && local.ack.enabled && local.ack.secret_manager_enabled ? 1 : 0

  version = "1"
  statement {
    effect   = "Allow"
    action   = ["kms:GetSecretValue", "kms:Decrypt"]
    resource = ["*"]
  }
}

resource "alicloud_ram_policy" "secrets_manager" {
  count = local.kms.enabled && local.ack.enabled && local.ack.secret_manager_enabled ? 1 : 0

  policy_name     = "secret-manager-policy"
  policy_document = data.alicloud_ram_policy_document.secrets_manager[0].document
  description     = "Secret manager policy"
}

resource "alicloud_ram_role_policy_attachment" "secrets_manager" {
  count = local.kms.enabled && local.ack.enabled && local.ack.secret_manager_enabled ? 1 : 0

  policy_name = alicloud_ram_policy.secrets_manager[0].policy_name
  policy_type = "Custom"
  role_name   = alicloud_cs_managed_kubernetes.ack[0].worker_ram_role_name
}

