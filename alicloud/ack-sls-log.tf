resource "alicloud_log_project" "ack_logtail_ds" {
  count = local.ack.enabled ? 1 : 0

  project_name = "${local.project}-cluster-logtail-${random_integer.random[0].result}"
  description  = "Logging project for ${local.project}-cluster"

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "alicloud_log_project" "ack_node_log" {
  count = local.ack.enabled ? 1 : 0

  project_name = "${local.project}-cluster-node-${random_integer.random[0].result}"
  description  = "Logging project for ${local.project}-cluster"

  lifecycle {
    ignore_changes = [tags]
  }
}
