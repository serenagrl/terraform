resource "aws_eip" "eips" {
  count = length(var.subnet_cidrs.public)

  domain = "vpc"

  tags = {
    Name = "${var.project}-eip-${data.aws_availability_zones.default.names[count.index]}"
  }
}

resource "aws_nat_gateway" "nats" {
  count = length(var.subnet_cidrs.public)

  allocation_id = aws_eip.eips[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id

  tags = {
    Name = "${var.project}-nat-public-${data.aws_availability_zones.default.names[count.index]}"
  }

  depends_on = [ aws_internet_gateway.igw ]
}