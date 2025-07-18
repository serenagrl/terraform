resource "alicloud_resource_manager_service_linked_role" "arms_role" {
  count = local.ack.enabled && local.ack.create_roles ? 1 : 0

  service_name = "arms.aliyuncs.com"
}

resource "random_integer" "random" {
  count = local.ack.enabled ? 1 : 0

  max = 99999
  min = 10000
}

resource "alicloud_cs_managed_kubernetes" "ack" {
  count = local.ack.enabled ? 1 : 0

  name              = "${local.project}-cluster"
  resource_group_id = alicloud_resource_manager_resource_group.ack.id
  cluster_spec      = local.ack.cluster_spec
  version           = local.ack.version
  vswitch_ids       = [alicloud_vswitch.private_vswitches[0].id, alicloud_vswitch.private_vswitches[1].id]
  pod_vswitch_ids   = [alicloud_vswitch.terway_vswitches[0].id, alicloud_vswitch.terway_vswitches[1].id]
  new_nat_gateway   = false
  node_cidr_mask    = 24
  service_cidr      = local.ack.service_cidr
  security_group_id = alicloud_security_group.ack[0].id

  #https://www.alibabacloud.com/help/en/ack/serverless-kubernetes/developer-reference/use-terraform-to-manage-components
  addons {
    name = "terway-eniip"
  }
  addons {
    name = "logtail-ds"
    config = jsonencode({
      IngressDashboardEnabled = "true"
      sls_project_name = "${alicloud_log_project.ack_logtail_ds[0].project_name}"
    })
  }
  addons {
    name = "nginx-ingress-controller"
    config = jsonencode({
      IngressSlbNetworkType = "internet"
    })
  }
  addons {
    name = "ack-node-problem-detector"
    config = jsonencode({
      sls_project_name = "${alicloud_log_project.ack_node_log[0].project_name}"
    })
  }

  depends_on = [
    alicloud_ram_role.ram_roles,
    alicloud_ram_role_policy_attachment.ram_roles_policy_attachment,
    alicloud_resource_manager_service_linked_role.arms_role,
    alicloud_log_project.ack_logtail_ds,
    alicloud_log_project.ack_node_log,
    alicloud_vpc.vpc,
    alicloud_vswitch.private_vswitches,
    alicloud_vswitch.terway_vswitches
  ]
}

resource "alicloud_cs_kubernetes_node_pool" "default" {
  count = local.ack.enabled ? 1 : 0

  node_pool_name       = "${local.project}-nodes"
  cluster_id           = alicloud_cs_managed_kubernetes.ack[0].id
  vswitch_ids          = [alicloud_vswitch.private_vswitches[0].id, alicloud_vswitch.private_vswitches[1].id]
  instance_types       = local.ack.instance_types
  instance_charge_type = "PostPaid"
  system_disk_category = local.ack.disk_category
  system_disk_size     = local.ack.disk_size
  image_type           = "ContainerOS"
  desired_size         = upper(local.ack.autoscaler_type) == "DEFAULT" ? null : local.ack.desired_nodes

  scaling_config {
    enable   = upper(local.ack.autoscaler_type) == "DEFAULT"
    min_size = local.ack.min_count
    max_size = local.ack.max_count
  }

  depends_on = [
    alicloud_ram_role.ram_roles,
    alicloud_ram_role_policy_attachment.ram_roles_policy_attachment,
    alicloud_cs_managed_kubernetes.ack
  ]
}
