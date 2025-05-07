resource "terraform_data" "gateway_type" {
  input = var.gateway_type
}

resource "aws_vpn_connection" "s2s_vpn" {
  vpn_gateway_id           = upper(var.gateway_type) == "VIRTUAL_PRIVATE" ? aws_vpn_gateway.virtual_private_gateway[0].id : null
  transit_gateway_id       = upper(var.gateway_type) == "TRANSIT" ? aws_ec2_transit_gateway.transit_gateway[0].id : null
  customer_gateway_id      = aws_customer_gateway.customer_gateway.id
  type                     = "ipsec.1"
  static_routes_only       = true
  remote_ipv4_network_cidr = var.vpc_cidr
  local_ipv4_network_cidr  = var.local_ipv4_cidr

  tunnel1_inside_cidr      = var.tunnel1_inside_cidr
  tunnel2_inside_cidr      = var.tunnel2_inside_cidr
  tunnel1_preshared_key    = var.tunnel1_preshared_key
  tunnel2_preshared_key    = var.tunnel2_preshared_key

  depends_on = [
    aws_customer_gateway.customer_gateway,
    aws_vpn_gateway.virtual_private_gateway,
    aws_ec2_transit_gateway.transit_gateway,
    aws_route.route_vpn_private_rtb,
  ]

  tags = {
    Name = "${var.project}-${upper(var.gateway_type) == "VIRTUAL_PRIVATE" ? "virtual-private" : "transit"}-gateway-vpn"
  }

  lifecycle {
    replace_triggered_by = [
      terraform_data.gateway_type
    ]
  }
}

resource "aws_route" "route_vpn_private_rtb" {
  count = length(var.private_route_table_ids)

  route_table_id         = var.private_route_table_ids[count.index]
  destination_cidr_block = var.local_ipv4_cidr
  gateway_id             = upper(var.gateway_type) == "VIRTUAL_PRIVATE" ? aws_vpn_gateway.virtual_private_gateway[0].id : null
  transit_gateway_id     = upper(var.gateway_type) == "TRANSIT" ? aws_ec2_transit_gateway.transit_gateway[0].id : null

  lifecycle {
    replace_triggered_by = [
      terraform_data.gateway_type
    ]
  }
}