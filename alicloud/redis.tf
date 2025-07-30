resource "random_password" "cache_password" {
  count = local.redis.enabled && (local.redis.password == null || local.redis.password == "") ? 1 : 0

  length  = 16
  special = false
}

# Please remove the deleted instance from the Recycle Bin in the portal.
resource "alicloud_kvstore_instance" "default" {
  count = local.redis.enabled ? 1 : 0

  db_instance_name  = local.redis.instance_name
  auto_renew        = false
  payment_type      = "PostPaid"

  resource_group_id = alicloud_resource_manager_resource_group.ack.id
  vswitch_id        = alicloud_vswitch.service_vswitch[0].id
  zone_id           = data.alicloud_zones.default.zones[0].id
  secondary_zone_id = local.redis.high_availability ? data.alicloud_zones.default.zones[1].id : null
  security_ips      = concat(local.vpc.vswitch_cidrs.pod, local.vpn.on_premise_cidr)
  instance_type     = "Redis"
  engine_version    = local.redis.engine_version
  instance_class    = local.redis.instance_class
  shard_count       = local.redis.shard_count
  ssl_enable        = "Enable"
  password          = local.redis.password != null && local.redis.password != "" ? local.redis.password : random_password.cache_password[0].result
}

output "cache_password" {
  sensitive   = true
  value       = try(coalesce(local.redis.password, random_password.cache_password[0].result), "null")
  description = "The initial password/token for cache when it was created."
}