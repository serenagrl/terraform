resource "alicloud_eip_address" "nats" {
  count = length(local.vpc.vswitch_cidrs.public)

  address_name         = "${local.project}-nat-ip-${data.alicloud_zones.default.zones[count.index].id}"
  payment_type         = "PayAsYouGo"
  internet_charge_type = "PayByTraffic"
  bandwidth            = 20

  depends_on = [ alicloud_vpc.vpc ]
}

resource "alicloud_nat_gateway" "nats" {
  count = length(local.vpc.vswitch_cidrs.public)

  vpc_id           = alicloud_vpc.vpc.id
  nat_gateway_name = "${local.project}-natgw-${data.alicloud_zones.default.zones[count.index].id}"
  payment_type     = "PayAsYouGo"
  vswitch_id       = alicloud_vswitch.public_vswitches[count.index].id
  nat_type         = "Enhanced"

  depends_on = [ alicloud_vpc.vpc ]
}

resource "alicloud_eip_association" "nats_gw_ip_assoc" {
  count = length(local.vpc.vswitch_cidrs.public)

  allocation_id = alicloud_eip_address.nats[count.index].id
  instance_id   = alicloud_nat_gateway.nats[count.index].id

  depends_on = [
    alicloud_nat_gateway.nats,
    alicloud_eip_address.nats
  ]
}

resource "alicloud_snat_entry" "private_nats" {
  count             = length(local.vpc.vswitch_cidrs.private)
  snat_entry_name   = "${local.project}-snat-${data.alicloud_zones.default.zones[count.index].id}"
  snat_table_id     = alicloud_nat_gateway.nats[count.index].snat_table_ids
  source_vswitch_id = alicloud_vswitch.private_vswitches[count.index].id
  snat_ip           = alicloud_eip_address.nats[count.index].ip_address
}

resource "alicloud_snat_entry" "pod_nats" {
  count             = length(local.vpc.vswitch_cidrs.pod)
  snat_entry_name   = "${local.project}-snat-${data.alicloud_zones.default.zones[count.index].id}"
  snat_table_id     = alicloud_nat_gateway.nats[count.index].snat_table_ids
  source_vswitch_id = alicloud_vswitch.terway_vswitches[count.index].id
  snat_ip           = alicloud_eip_address.nats[count.index].ip_address
}
