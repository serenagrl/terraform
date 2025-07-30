# https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vpn_connection
resource "alicloud_vpn_connection" "s2s_vpn" {
  count = local.vpn.enabled ? 1 : 0

  vpn_gateway_id      = alicloud_vpn_gateway.alicloud[0].id
  vpn_connection_name = "${local.project}-vpn-local"

  local_subnet  = [ local.vpc.cidr ]
  remote_subnet = local.vpn.on_premise_cidr

  network_type         = "public"
  enable_tunnels_bgp   = false

  tunnel_options_specification {
    customer_gateway_id = alicloud_vpn_customer_gateway.on_premise[0].id
    role                = "master"
    enable_dpd           = true
    enable_nat_traversal = true

    tunnel_ipsec_config {
      ipsec_auth_alg = "sha1"
      ipsec_enc_alg  = "aes"
      ipsec_lifetime = "3600"
      ipsec_pfs      = "disabled"
    }

    tunnel_ike_config {
      ike_mode     = "main"
      ike_version  = "ikev2"
      psk          = local.vpn.tunnel1_preshared_key
      ike_auth_alg = "sha1"
      ike_enc_alg  = "aes"
      ike_lifetime = "28800"
      ike_pfs      = "group2"
    }
  }

  tunnel_options_specification {
    customer_gateway_id = alicloud_vpn_customer_gateway.on_premise[0].id
    role                = "slave"
    enable_dpd           = true
    enable_nat_traversal = true

    tunnel_ipsec_config {
      ipsec_auth_alg = "sha1"
      ipsec_enc_alg  = "aes"
      ipsec_lifetime = "3600"
      ipsec_pfs      = "disabled"
    }

    tunnel_ike_config {
      ike_mode     = "main"
      ike_version  = "ikev2"
      psk          = local.vpn.tunnel2_preshared_key
      ike_auth_alg = "sha1"
      ike_enc_alg  = "aes"
      ike_lifetime = "28800"
      ike_pfs      = "group2"
    }
  }
}

resource "alicloud_route_entry" "on_premise_private" {
  count = local.vpn.enabled ? length(local.vpc.vswitch_cidrs.private) : 0

  name                  = "${local.project}-on-premise-route"
  route_table_id        = alicloud_route_table.private_rtbs[count.index].id
  destination_cidrblock = local.vpn.on_premise_cidr[0]
  nexthop_type          = "VpnGateway"
  nexthop_id            = alicloud_vpn_gateway.alicloud[0].id
}

resource "alicloud_route_entry" "on_premise_pod" {
  count = local.vpn.enabled ? length(local.vpc.vswitch_cidrs.pod) : 0

  name                  = "${local.project}-on-premise-route"
  route_table_id        = alicloud_route_table.pod_rtbs[count.index].id
  destination_cidrblock = local.vpn.on_premise_cidr[0]
  nexthop_type          = "VpnGateway"
  nexthop_id            = alicloud_vpn_gateway.alicloud[0].id
}

resource "alicloud_route_entry" "on_premise_service" {
  count = local.vpn.enabled && local.vpc.create_service_vswitch ? 1 : 0

  name                  = "${local.project}-on-premise-route"
  route_table_id        = alicloud_route_table.service_rtb[0].id
  destination_cidrblock = local.vpn.on_premise_cidr[0]
  nexthop_type          = "VpnGateway"
  nexthop_id            = alicloud_vpn_gateway.alicloud[0].id
}
