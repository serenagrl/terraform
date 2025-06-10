# Note: vpc_id & vswitch_id is only available for cpfs file system.
resource "alicloud_nas_file_system" "file_csi" {
  count = local.ack.enabled ? 1 : 0

  protocol_type    = "NFS"
  storage_type     = "Capacity"
  description      = "${local.project}-nas-file-system"
  encrypt_type     = 0
  file_system_type = "standard"
  zone_id          = data.alicloud_zones.default.zones[0].id

  recycle_bin {
    status         = local.ack.csi_recycle_bin_enabled ? "Enable" : null
    reserved_days  = local.ack.csi_recycle_bin_reserved_days
  }

  lifecycle {
    ignore_changes = [tags]
  }

  depends_on = [
    alicloud_cs_managed_kubernetes.ack,
    alicloud_cs_kubernetes_node_pool.default
  ]
}

resource "alicloud_nas_access_group" "file_csi" {
  count = local.ack.enabled ? 1 : 0

  access_group_name = "${local.project}-nas-access-group"
  access_group_type = "Vpc"
  description       = "${local.project}-nas-access-group"
  file_system_type  = alicloud_nas_file_system.file_csi[0].file_system_type

  depends_on = [
    alicloud_cs_managed_kubernetes.ack,
    alicloud_cs_kubernetes_node_pool.default
  ]
}

# Note: Requires ACK Node's CIDR range.
resource "alicloud_nas_access_rule" "file_csi" {
  count = local.ack.enabled ? length(local.vpc.vswitch_cidrs.private) : 0

  access_group_name   = alicloud_nas_access_group.file_csi[0].access_group_name
  rw_access_type      = "RDWR"
  source_cidr_ip      = local.vpc.vswitch_cidrs.private[count.index]
  user_access_type    = "no_squash"
  priority            = "1"
  file_system_type    = alicloud_nas_file_system.file_csi[0].file_system_type

  depends_on = [
    alicloud_cs_managed_kubernetes.ack,
    alicloud_cs_kubernetes_node_pool.default
  ]
}

resource "alicloud_nas_mount_target" "file_csi" {
  count = local.ack.enabled ? 1 : 0

  file_system_id    = alicloud_nas_file_system.file_csi[0].id
  access_group_name = alicloud_nas_access_group.file_csi[0].access_group_name
  vswitch_id        = alicloud_vswitch.private_vswitches[0].id
  vpc_id            = alicloud_vpc.vpc.id
  network_type      = alicloud_nas_access_group.file_csi[0].access_group_type

  depends_on = [
    alicloud_cs_managed_kubernetes.ack,
    alicloud_cs_kubernetes_node_pool.default
  ]
}

# Custom helm-chart to create cnfs.
resource "helm_release" "configure_cnfs" {
  count = local.ack.enabled ? 1 : 0

  name             = "configure-cnfs"
  chart            = "./charts/configure-cnfs"

  set {
    name  = "server"
    value = alicloud_nas_mount_target.file_csi[0].mount_target_domain
  }

  depends_on = [
    alicloud_cs_managed_kubernetes.ack,
    alicloud_cs_kubernetes_node_pool.default,
    data.alicloud_cs_cluster_credential.ack,
    helm_release.cert_manager
  ]
}