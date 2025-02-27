resource "aws_eip" "eip1" {
  domain = "vpc"

  tags = {
    Name = "${var.project}-eip-${var.region}a"
  }
}

resource "aws_eip" "eip2" {
  domain = "vpc"

  tags = {
    Name = "${var.project}-eip-${var.region}b"
  }
}

resource "aws_nat_gateway" "nat_gw1" {
  allocation_id = aws_eip.eip1.id
  subnet_id     = aws_subnet.public_subnet1.id

  tags = {
    Name = "${var.project}-nat-public1-${var.region}a"
  }

  depends_on = [ aws_internet_gateway.igw ]
}

resource "aws_nat_gateway" "nat_gw2" {
  allocation_id = aws_eip.eip2.id
  subnet_id     = aws_subnet.public_subnet2.id

  tags = {
    Name = "${var.project}-nat-public2-${var.region}b"
  }

  depends_on = [ aws_internet_gateway.igw ]

}