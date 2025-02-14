resource "aws_eip" "eip1" {
  domain = "vpc"

  tags = {
    Name = "${local.project}-eip-${local.region}a"
  }
}

resource "aws_eip" "eip2" {
  domain = "vpc"

  tags = {
    Name = "${local.project}-eip-${local.region}b"
  }
}

resource "aws_nat_gateway" "nat_gw1" {
  allocation_id = aws_eip.eip1.id
  subnet_id     = aws_subnet.public_subnet1.id

  tags = {
    Name = "${local.project}-nat-public1-${local.region}a"
  }

  depends_on = [ aws_internet_gateway.igw ]
}

resource "aws_nat_gateway" "nat_gw2" {
  allocation_id = aws_eip.eip2.id
  subnet_id     = aws_subnet.public_subnet2.id

  tags = {
    Name = "${local.project}-nat-public2-${local.region}b"
  }

  depends_on = [ aws_internet_gateway.igw ]

}