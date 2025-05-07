# Get current public IP address for setting up VPN.
data "curl" "get_public_ip" {
  http_method = "GET"
  uri = "https://ipv4.icanhazip.com"
}

resource "aws_customer_gateway" "customer_gateway" {
  bgp_asn    = 65000
  ip_address = coalesce(var.customer_gateway_ip, trimspace(data.curl.get_public_ip.response))
  type       = "ipsec.1"

  tags = {
    Name = "${var.project}-customer-gateway"
  }
}