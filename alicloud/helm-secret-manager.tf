# Note: Source is from https://github.com/AliyunContainerService/ack-secret-manager
resource "null_resource" "clone_secret_manager" {
  count = local.kms.enabled && local.ack.enabled && local.ack.secret_manager_enabled ? 1 : 0

  provisioner "local-exec" {
    command = "chmod +x ${path.module}/shells/clone-ack-secret-manager.sh; ${path.module}/shells/clone-ack-secret-manager.sh"
  }

  depends_on = [
    alicloud_cs_managed_kubernetes.ack,
    alicloud_cs_kubernetes_node_pool.default
  ]
}

resource "helm_release" "secret_manager" {
  count = local.kms.enabled && local.ack.enabled && local.ack.secret_manager_enabled ? 1 : 0

  name             = "secret-manager"
  chart            = "/tmp/ack-secret-manager"
  namespace        = "kube-system"
  wait             = true

  values = [templatefile("${path.module}/values/ack-secret-manager.yaml", {
    region    = local.region
  })]

  depends_on = [
    alicloud_cs_managed_kubernetes.ack,
    alicloud_cs_kubernetes_node_pool.default,
    data.alicloud_cs_cluster_credential.ack,
    alicloud_kms_instance.kms,
    null_resource.clone_secret_manager
  ]
}

data "alicloud_ram_policy_document" "secret_manager" {
  count = local.kms.enabled && local.ack.enabled && local.ack.secret_manager_enabled ? 1 : 0

  version = "1"
  statement {
    effect   = "Allow"
    action   = ["kms:GetSecretValue", "kms:Decrypt"]
    resource = ["*"]
  }
}

resource "alicloud_ram_policy" "secret_manager" {
  count = local.kms.enabled && local.ack.enabled && local.ack.secret_manager_enabled ? 1 : 0

  policy_name     = "secret-manager-policy"
  policy_document = data.alicloud_ram_policy_document.secret_manager[0].document
  description     = "Secret manager policy"
}

resource "alicloud_ram_role_policy_attachment" "secret_manager" {
  count = local.kms.enabled && local.ack.enabled && local.ack.secret_manager_enabled ? 1 : 0

  policy_name = alicloud_ram_policy.secret_manager[0].policy_name
  policy_type = "Custom"
  role_name   = alicloud_cs_managed_kubernetes.ack[0].worker_ram_role_name
}

