output "id" {
  value = aws_vpc.vpc.id
}

output "vpc" {
  value = aws_vpc.vpc
}

output "public_subnet1" {
  value = aws_subnet.public_subnet1
}

output "public_subnet2" {
  value = aws_subnet.public_subnet2
}

output "private_subnet1" {
  value = aws_subnet.private_subnet1
}

output "private_subnet2" {
  value = aws_subnet.private_subnet2
}

output "database_subnet1" {
  value = aws_subnet.database_subnet1
}

output "database_subnet2" {
  value = aws_subnet.database_subnet2
}

output "public_rtb" {
  value = aws_route_table.public_rtb
}

output "private_rtb1" {
  value = aws_route_table.private_rtb1
}

output "private_rtb2" {
  value = aws_route_table.private_rtb2
}