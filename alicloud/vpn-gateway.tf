
resource "alicloud_resource_manager_service_linked_role" "nat_roles" {
  count = local.vpn.enabled && local.vpn.create_roles ? 1 : 0

  service_name = "AliyunServiceRoleForNatgw"
}

resource "alicloud_vpn_gateway" "alicloud" {
  count = local.vpn.enabled ? 1 : 0

  vpn_type          = "Normal"
  vpn_gateway_name  = "${local.project}-vpn-gateway"
  description       = "${local.project} VPN Gateway"
  resource_group_id = alicloud_resource_manager_resource_group.ack.id
  vpc_id            = alicloud_vpc.vpc.id
  auto_pay          = true
  network_type      = "public"
  payment_type      = "PayAsYouGo"
  enable_ipsec      = true
  bandwidth         = 200

  vswitch_id                   = alicloud_vswitch.private_vswitches[0].id
  disaster_recovery_vswitch_id = alicloud_vswitch.private_vswitches[1].id

  depends_on = [ alicloud_resource_manager_service_linked_role.nat_roles ]
}