data "aws_availability_zones" "default" {
}

resource "aws_subnet" "database_subnets" {
  count = length(var.subnet_cidrs)

  vpc_id               = var.vpc_id
  cidr_block           = var.subnet_cidrs[count.index]
  availability_zone_id = data.aws_availability_zones.default.zone_ids[count.index]

  tags = {
    Name = "${var.project}-subnet-database${data.aws_availability_zones.default.names[count.index]}"
    "kubernetes.io/role/internal-elb" = "1"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_route_table_association" "database_zones" {
  count = length(aws_subnet.database_subnets)

  subnet_id      = aws_subnet.database_subnets[count.index].id
  route_table_id = var.private_route_table_ids[count.index]
}
