output "id" {
  value = aws_vpc.vpc.id
}

output "vpc" {
  value = aws_vpc.vpc
}

output "public_subnets" {
  value = aws_subnet.public_subnets
}

output "private_subnets" {
  value = aws_subnet.private_subnets
}

output "public_rtb" {
  value = aws_route_table.public_rtb
}

output "private_rtbs" {
  value = aws_route_table.private_rtbs
}