resource "terraform_data" "gateway_type" {
  input = local.vpn.gateway_type
}

resource "aws_vpn_connection" "site_to_site_vpn" {
  count = local.vpn.enabled ? 1 : 0

  vpn_gateway_id           = local.vpn.gateway_type == "virtual" ? aws_vpn_gateway.virtual_private_gateway[0].id : null
  transit_gateway_id       = local.vpn.gateway_type == "transit" ? aws_ec2_transit_gateway.transit_gateway[0].id : null
  customer_gateway_id      = aws_customer_gateway.customer_gateway[0].id
  type                     = "ipsec.1"
  static_routes_only       = true
  remote_ipv4_network_cidr = local.vpc_cidr
  local_ipv4_network_cidr  = local.vpn.local_ipv4_cidr

  tunnel1_inside_cidr      = local.vpn.tunnel1_inside_cidr
  tunnel2_inside_cidr      = local.vpn.tunnel2_inside_cidr
  tunnel1_preshared_key    = local.vpn.tunnel1_preshared_key
  tunnel2_preshared_key    = local.vpn.tunnel2_preshared_key

  depends_on = [
    aws_customer_gateway.customer_gateway,
    aws_vpn_gateway.virtual_private_gateway,
    aws_ec2_transit_gateway.transit_gateway,
    aws_route.route_vpn_private_rtb1,
    aws_route.route_vpn_private_rtb2
  ]

  tags = {
    Name = "${local.project}-${local.vpn.gateway_type == "virtual" ? "virtual-private" : "transit"}-gateway-vpn"
  }

  lifecycle {
    replace_triggered_by = [
      terraform_data.gateway_type
    ]
  }
}

resource "aws_route" "route_vpn_private_rtb1" {
  count = local.vpn.enabled ? 1 : 0

  route_table_id              = aws_route_table.private_rtb1.id
  destination_cidr_block      = local.vpn.local_ipv4_cidr
  gateway_id                  = local.vpn.gateway_type == "virtual" ? aws_vpn_gateway.virtual_private_gateway[0].id : null
  transit_gateway_id          = local.vpn.gateway_type == "transit" ? aws_ec2_transit_gateway.transit_gateway[0].id : null

  lifecycle {
    replace_triggered_by = [
      terraform_data.gateway_type
    ]
  }
}

resource "aws_route" "route_vpn_private_rtb2" {
  count = local.vpn.enabled ? 1 : 0

  route_table_id              = aws_route_table.private_rtb2.id
  destination_cidr_block      = local.vpn.local_ipv4_cidr
  gateway_id                  = local.vpn.gateway_type == "virtual" ? aws_vpn_gateway.virtual_private_gateway[0].id : null
  transit_gateway_id          = local.vpn.gateway_type == "transit" ? aws_ec2_transit_gateway.transit_gateway[0].id : null

  lifecycle {
    replace_triggered_by = [
      terraform_data.gateway_type
    ]
  }
}