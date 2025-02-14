resource "aws_ec2_transit_gateway" "transit_gateway" {
  count = local.vpn.enabled && local.vpn.gateway_type == "transit" ? 1 : 0

  description = "Transit gateway"

  tags = {
    Name = "${local.project}-tgw"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_vpc_attachment" {
  count = local.vpn.enabled && local.vpn.gateway_type == "transit" ? 1 : 0

  subnet_ids         = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway[0].id
  vpc_id             = aws_vpc.vpc.id

  dns_support        = "enable"

  tags = {
    Name = "${local.project}-tgw-vpc-attachment"
  }

}

resource "aws_ec2_transit_gateway_route" "static_route" {
  count = local.vpn.enabled && local.vpn.gateway_type == "transit" ? 1 : 0

  destination_cidr_block         = local.vpn.local_ipv4_cidr
  transit_gateway_attachment_id  = aws_vpn_connection.site_to_site_vpn[0].transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.transit_gateway[0].association_default_route_table_id
}
