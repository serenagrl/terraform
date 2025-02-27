resource "aws_vpn_gateway" "virtual_private_gateway" {
  count = upper(var.gateway_type) == "VIRTUAL_PRIVATE" ? 1 : 0

  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project}-vpgw"
  }
}

resource "aws_vpn_connection_route" "static_route" {
  count = upper(var.gateway_type) == "VIRTUAL_PRIVATE" ? 1 : 0

  destination_cidr_block = var.local_ipv4_cidr
  vpn_connection_id      = aws_vpn_connection.site_to_site_vpn.id
}
