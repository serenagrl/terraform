resource "aws_vpn_gateway" "virtual_private_gateway" {
  count = local.vpn.enabled && local.vpn.gateway_type == "virtual" ? 1 : 0

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${local.project}-vpgw"
  }
}

resource "aws_vpn_connection_route" "static_route" {
  count = local.vpn.enabled && local.vpn.gateway_type == "virtual" ? 1 : 0

  destination_cidr_block = local.vpn.local_ipv4_cidr
  vpn_connection_id      = aws_vpn_connection.site_to_site_vpn[0].id
}
