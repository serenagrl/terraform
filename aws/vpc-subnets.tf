resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${local.subnets.public_cidrs[0]}"
  availability_zone       = "${local.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.project}-subnet-public1-${local.region}a"
    "kubernetes.io/role/elb" = "1"
  }

  depends_on = [aws_vpc.vpc]

}

resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${local.subnets.public_cidrs[1]}"
  availability_zone       = "${local.region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.project}-subnet-public2-${local.region}b"
    "kubernetes.io/role/elb" = "1"
  }

  depends_on = [aws_vpc.vpc]

}

resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "${local.subnets.private_cidrs[0]}"
  availability_zone = "${local.region}a"

  tags = {
    Name = "${local.project}-subnet-private1-${local.region}a"
    "kubernetes.io/role/internal-elb" = "1"
  }

  depends_on = [aws_vpc.vpc]

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "${local.subnets.private_cidrs[1]}"
  availability_zone = "${local.region}b"

  tags = {
    Name = "${local.project}-subnet-private2-${local.region}b"
    "kubernetes.io/role/internal-elb" = "1"
  }

  depends_on = [aws_vpc.vpc]

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_subnet" "database_subnet1" {
  count = length(local.subnets.database_cidrs) > 0 ? 1 : 0

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "${local.subnets.database_cidrs[0]}"
  availability_zone = "${local.region}a"

  tags = {
    Name = "${local.project}-subnet-database1-${local.region}b"
    "kubernetes.io/role/internal-elb" = "1"
  }

  depends_on = [aws_vpc.vpc]

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_subnet" "database_subnet2" {
  count = length(local.subnets.database_cidrs) > 0 ? 1 : 0

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "${local.subnets.database_cidrs[1]}"
  availability_zone = "${local.region}b"

  tags = {
    Name = "${local.project}-subnet-database2-${local.region}b"
    "kubernetes.io/role/internal-elb" = "1"
  }

  depends_on = [aws_vpc.vpc]

  lifecycle {
    ignore_changes = [tags]
  }
}