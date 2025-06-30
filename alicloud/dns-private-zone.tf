resource "alicloud_pvtz_zone" "internal_zone" {
  count = local.dns_pvtz.enabled ? 1 : 0

  zone_name         = local.dns_pvtz.zone_name
  resource_group_id = alicloud_resource_manager_resource_group.ack.id
}

resource "alicloud_pvtz_zone_attachment" "zone-attachment" {
  count = local.dns_pvtz.enabled ? 1 : 0

  zone_id = alicloud_pvtz_zone.internal_zone[0].id
  vpc_ids = [alicloud_vpc.vpc.id]
}