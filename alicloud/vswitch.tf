data "alicloud_zones" "default" {}

resource "alicloud_vswitch" "public_vswitches" {
  count = length(local.vpc.vswitch_cidrs.public)

  vswitch_name = "${local.project}-public-vswitch-${data.alicloud_zones.default.zones[count.index].id}"
  cidr_block   = local.vpc.vswitch_cidrs.public[count.index]
  vpc_id       = alicloud_vpc.vpc.id
  zone_id      = data.alicloud_zones.default.zones[count.index].id

  depends_on = [ alicloud_vpc.vpc ]
}

resource "alicloud_vswitch" "private_vswitches" {
  count = length(local.vpc.vswitch_cidrs.private)

  vswitch_name = "${local.project}-private-vswitch-${data.alicloud_zones.default.zones[count.index].id}"
  cidr_block   = local.vpc.vswitch_cidrs.private[count.index]
  vpc_id       = alicloud_vpc.vpc.id
  zone_id      = data.alicloud_zones.default.zones[count.index].id

  tags = local.karpenter_tag
  
  depends_on = [ alicloud_vpc.vpc ]
}

resource "alicloud_vswitch" "terway_vswitches" {
  count = length(local.vpc.vswitch_cidrs.pod)

  vswitch_name = "${local.project}-pod-vswitch-${data.alicloud_zones.default.zones[count.index].id}"
  cidr_block   = local.vpc.vswitch_cidrs.pod[count.index]
  vpc_id       = alicloud_vpc.vpc.id
  zone_id      = data.alicloud_zones.default.zones[count.index].id

  depends_on = [ alicloud_vpc.vpc ]

}