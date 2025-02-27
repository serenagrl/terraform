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

resource "aws_route_table" "private_rtb1" {
  vpc_id = aws_vpc.vpc.id

   route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw1.id
  }

  tags = {
    Name = "${var.project}-rtb-private1-${var.region}a"
  }
  lifecycle {
    ignore_changes = [route]
  }
}

resource "aws_route_table" "private_rtb2" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw2.id
  }

  tags = {
    Name = "${var.project}-rtb-private2-${var.region}b"
  }
  lifecycle {
    ignore_changes = [route]
  }
}

resource "aws_route_table_association" "public_zone1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_route_table_association" "public_zone2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_route_table_association" "private_zone1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_rtb1.id
}

resource "aws_route_table_association" "private_zone2" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private_rtb2.id
}

resource "aws_route_table_association" "database_zone1" {
  count = length(var.subnet_cidrs.database) > 0 ? 1 : 0

  subnet_id      = aws_subnet.database_subnet1[0].id
  route_table_id = aws_route_table.private_rtb1.id
}

resource "aws_route_table_association" "database_zone2" {
  count = length(var.subnet_cidrs.database) > 0 ? 1 : 0

  subnet_id      = aws_subnet.database_subnet2[0].id
  route_table_id = aws_route_table.private_rtb2.id
}
