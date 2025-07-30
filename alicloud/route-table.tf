resource "alicloud_route_table" "private_rtbs" {
  count = length(local.vpc.vswitch_cidrs.private)

  route_table_name = "${local.project}-rtb-private-${data.alicloud_zones.default.zones[count.index].id}"
  description      = "Private Subnet Route to Public Subnet"
  vpc_id           = alicloud_vpc.vpc.id
  associate_type   = "VSwitch"
}

resource "alicloud_route_entry" "private_routes" {
  count = length(local.vpc.vswitch_cidrs.private)

  name                  = "${local.project}-nat-route"
  route_table_id        = alicloud_route_table.private_rtbs[count.index].id
  destination_cidrblock = "0.0.0.0/0"
  nexthop_type          = "NatGateway"
  nexthop_id            = alicloud_nat_gateway.nats[count.index].id
}

resource "alicloud_route_table_attachment" "private_attachment" {
  count = length(local.vpc.vswitch_cidrs.private)

  vswitch_id     = alicloud_vswitch.private_vswitches[count.index].id
  route_table_id = alicloud_route_table.private_rtbs[count.index].id
}

resource "alicloud_route_table" "pod_rtbs" {
  count = length(local.vpc.vswitch_cidrs.pod)

  route_table_name = "${local.project}-rtb-pod-${data.alicloud_zones.default.zones[count.index].id}"
  description      = "Pod Subnet Route to Public Subnet"
  vpc_id           = alicloud_vpc.vpc.id
  associate_type   = "VSwitch"
}

resource "alicloud_route_entry" "pod_routes" {
  count = length(local.vpc.vswitch_cidrs.pod)

  route_table_id        = alicloud_route_table.pod_rtbs[count.index].id
  destination_cidrblock = "0.0.0.0/0"
  nexthop_type          = "NatGateway"
  nexthop_id            = alicloud_nat_gateway.nats[count.index].id
}

resource "alicloud_route_table_attachment" "pod_attachment" {
  count = length(local.vpc.vswitch_cidrs.pod)

  vswitch_id     = alicloud_vswitch.terway_vswitches[count.index].id
  route_table_id = alicloud_route_table.pod_rtbs[count.index].id
}

resource "alicloud_route_table" "service_rtb" {
  count = local.vpc.create_service_vswitch ? 1 : 0

  route_table_name = "${local.project}-rtb-service"
  description      = "Service VSwitch Route Table"
  vpc_id           = alicloud_vpc.vpc.id
  associate_type   = "VSwitch"
}

resource "alicloud_route_entry" "service_routes" {
  count = local.vpc.create_service_vswitch ? 1 : 0

  route_table_id        = alicloud_route_table.service_rtb[0].id
  destination_cidrblock = "0.0.0.0/0"
  nexthop_type          = "NatGateway"
  nexthop_id            = alicloud_nat_gateway.nats[count.index].id
}

resource "alicloud_route_table_attachment" "service_attachment" {
  count = local.vpc.create_service_vswitch ? 1 : 0

  vswitch_id     = alicloud_vswitch.service_vswitch[0].id
  route_table_id = alicloud_route_table.service_rtb[0].id
}