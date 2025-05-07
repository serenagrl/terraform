resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project}-rtb-public"
  }

  lifecycle {
    ignore_changes = [route]
  }
}

resource "aws_route_table" "private_rtbs" {
  count = length(var.subnet_cidrs.private)

  vpc_id = aws_vpc.vpc.id

   route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nats[count.index].id
  }

  tags = {
    Name = "${var.project}-rtb-private-${data.aws_availability_zones.default.names[count.index]}"
  }
  lifecycle {
    ignore_changes = [route]
  }
}

resource "aws_route_table_association" "public_zones" {
  count = length(aws_subnet.public_subnets)

  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_route_table_association" "private_zones" {
  count = length(aws_subnet.private_subnets)

  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rtbs[count.index].id
}
