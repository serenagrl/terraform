resource "aws_ec2_transit_gateway" "transit_gateway" {
  count = upper(var.gateway_type) == "TRANSIT" ? 1 : 0

  description = "Transit gateway"

  tags = {
    Name = "${var.project}-transit-gateway"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_vpc_attachment" {
  count = upper(var.gateway_type) == "TRANSIT" ? 1 : 0

  subnet_ids         = var.transit_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway[0].id
  vpc_id             = var.vpc_id

  dns_support        = "enable"

  tags = {
    Name = "${var.project}-tgw-vpc-attachment"
  }

}

resource "aws_ec2_transit_gateway_route" "static_route" {
  count = upper(var.gateway_type) == "TRANSIT" ? 1 : 0

  destination_cidr_block         = var.local_ipv4_cidr
  transit_gateway_attachment_id  = aws_vpn_connection.s2s_vpn.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.transit_gateway[0].association_default_route_table_id
}
