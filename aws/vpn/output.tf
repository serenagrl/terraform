output "public_ip" {
  value = aws_customer_gateway.customer_gateway.ip_address
  description = "The public IP of the customer gateway."
}