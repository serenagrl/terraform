data "aws_availability_zones" "default" {
}
resource "aws_subnet" "public_subnets" {
  count = length(var.subnet_cidrs.public)

  vpc_id               = aws_vpc.vpc.id
  cidr_block           = var.subnet_cidrs.public[count.index]
  availability_zone_id = data.aws_availability_zones.default.zone_ids[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-subnet-public-${data.aws_availability_zones.default.names[count.index]}"
    "kubernetes.io/role/elb" = "1"
  }

  depends_on = [aws_vpc.vpc]

}

resource "aws_subnet" "private_subnets" {
  count = length(var.subnet_cidrs.private)

  vpc_id               = aws_vpc.vpc.id
  cidr_block           = var.subnet_cidrs.private[count.index]
  availability_zone_id = data.aws_availability_zones.default.zone_ids[count.index]

  tags = {
    Name = "${var.project}-subnet-private-${data.aws_availability_zones.default.names[count.index]}"
    "kubernetes.io/role/internal-elb" = "1"
  }

  depends_on = [aws_vpc.vpc]

  lifecycle {
    ignore_changes = [tags]
  }
}