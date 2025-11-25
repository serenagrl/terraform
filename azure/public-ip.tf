# Get current public IP address.
data "curl" "get_public_ip" {
  count = (local.local_gateway_ip == null || local.local_gateway_ip == "") ? 1 : 0
  
  http_method = "GET"
  uri         = "https://ipv4.icanhazip.com"
}