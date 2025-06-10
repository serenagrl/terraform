# Get current public IP address for setting up VPN.
data "curl" "get_public_ip" {
  count = local.vpn.enabled ? 1 : 0

  http_method = "GET"
  uri         = "https://ipv4.icanhazip.com"
}

resource "alicloud_vpn_customer_gateway" "on_premise" {
  count = local.vpn.enabled ? 1 : 0

  customer_gateway_name = "${local.project}-customer-gateway"
  description           = "On-Premise Customer Gateway"
  ip_address            = coalesce(local.vpn.customer_gateway_ip, trimspace(data.curl.get_public_ip[0].response))
  asn                   = "1219002"
}
