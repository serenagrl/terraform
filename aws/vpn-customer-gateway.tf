# Get current public IP address for setting up VPN.
data "curl" "get_public_ip" {
  http_method = "GET"
  uri = "https://ipv4.icanhazip.com"
}

resource "aws_customer_gateway" "customer_gateway" {
  count = local.vpn.enabled ? 1 : 0

  bgp_asn    = 65000
  ip_address = coalesce(local.vpn.customer_gateway_ip, trimspace(data.curl.get_public_ip.response))
  type       = "ipsec.1"

  tags = {
    Name = "${local.project}-cgw"
  }
}

output "public_ip" {
  value = aws_customer_gateway.customer_gateway[0].ip_address
  description = "The public IP of the customer gateway."
}
