resource "alicloud_rds_service_linked_role" "postgres" {
  count = local.postgres.enabled && local.postgres.create_roles ? 1 : 0

  service_name = "AliyunServiceRoleForRdsPgsqlOnEcs"
}

resource "alicloud_vswitch" "database" {
  count = local.postgres.enabled ? length(local.postgres.vswitch_cidrs) : 0

  vswitch_name = "${local.project}-db-vswitch-${data.alicloud_zones.default.zones[count.index].id}"
  cidr_block   = local.postgres.vswitch_cidrs[count.index]
  vpc_id       = alicloud_vpc.vpc.id
  zone_id      = data.alicloud_zones.default.zones[count.index].id

  depends_on = [ alicloud_vpc.vpc ]
}

resource "alicloud_route_table_attachment" "postgres" {
  count = local.postgres.enabled ? length(local.postgres.vswitch_cidrs) : 0

  vswitch_id     = alicloud_vswitch.database[count.index].id
  route_table_id = alicloud_route_table.private_rtbs[count.index].id

  depends_on = [
    alicloud_vswitch.database,
    alicloud_route_table.private_rtbs
  ]
}

resource "alicloud_db_instance" "postgres" {
  count = local.postgres.enabled ? 1 : 0

  engine                   = "PostgreSQL"
  engine_version           = local.postgres.version
  instance_storage         = local.postgres.instance_storage
  instance_type            = local.postgres.instance_type
  instance_charge_type     = "Postpaid"
  instance_name            = "${local.project}-postgres"
  connection_string_prefix = "${local.project}-postgres-rnd"
  zone_id                  = data.alicloud_zones.default.zones[0].id
  zone_id_slave_a          = local.postgres.cluster_enabled ? data.alicloud_zones.default.zones[1].id : null
  vswitch_id               = local.postgres.cluster_enabled ? "${alicloud_vswitch.database[0].id},${alicloud_vswitch.database[1].id}" : alicloud_vswitch.database[0].id
  vpc_id                   = alicloud_vpc.vpc.id
  db_instance_storage_type = "general_essd"
  security_ips             = concat(local.vpc.vswitch_cidrs.pod, local.vpn.on_premise_cidr)
  resource_group_id        = alicloud_resource_manager_resource_group.ack.id

  depends_on = [
    alicloud_vswitch.database,
    alicloud_rds_service_linked_role.postgres
  ]
}

resource "random_password" "postgres_password" {
  count = local.postgres.enabled && (local.postgres.password == null || local.postgres.password == "") ? 1 : 0

  length  = 16
  special = false
}

resource "alicloud_rds_account" "postgres" {
  count = local.postgres.enabled ? 1 : 0

  db_instance_id   = alicloud_db_instance.postgres[0].id
  account_name     = local.postgres.username
  account_password = local.postgres.password != null && local.postgres.password != "" ? local.postgres.password : random_password.postgres_password[0].result
  account_type     = "Super"

  depends_on = [ alicloud_db_instance.postgres ]
}

data "external" "get_secondary_node_id" {
  count = local.postgres.enabled && local.postgres.cluster_enabled && upper(regex(".*[.](.*)", local.postgres.instance_type)[0]) == "XC" ? 1 : 0

  program = ["bash", "${path.module}/shells/get-node-id.sh"]

  query = {
    dbInstanceId = alicloud_db_instance.postgres[0].id
  }

  depends_on = [
    alicloud_db_instance.postgres
  ]
}

resource "alicloud_rds_db_instance_endpoint" "postgres" {
  count = local.postgres.enabled && local.postgres.cluster_enabled && upper(regex(".*[.](.*)", local.postgres.instance_type)[0]) == "XC" ? 1 : 0

  db_instance_id                   = alicloud_db_instance.postgres[0].id
  vpc_id                           = alicloud_vpc.vpc.id
  vswitch_id                       = alicloud_db_instance.postgres[0].vswitch_id
  connection_string_prefix         = "${local.project}-postgres-readonly"
  port                             = "5432"
  db_instance_endpoint_description = "Endpoint for readonly replica."

  node_items {
    node_id = data.external.get_secondary_node_id[0].result.NodeId
    weight  = 100
  }

  depends_on = [
    alicloud_db_instance.postgres,
    data.external.get_secondary_node_id
  ]
}

output "postgres_password" {
  sensitive = true
  value = try(alicloud_rds_account.postgres[0].account_password, "null")
  description = "The initial password for postgres when it was created."

  depends_on = [ alicloud_rds_account.postgres ]
}