resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${var.subnet_cidrs.public[0]}"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-subnet-public1-${var.region}a"
    "kubernetes.io/role/elb" = "1"
  }

  depends_on = [aws_vpc.vpc]

}

resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "${var.subnet_cidrs.public[1]}"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-subnet-public2-${var.region}b"
    "kubernetes.io/role/elb" = "1"
  }

  depends_on = [aws_vpc.vpc]

}

resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "${var.subnet_cidrs.private[0]}"
  availability_zone = "${var.region}a"

  tags = {
    Name = "${var.project}-subnet-private1-${var.region}a"
    "kubernetes.io/role/internal-elb" = "1"
  }

  depends_on = [aws_vpc.vpc]

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "${var.subnet_cidrs.private[1]}"
  availability_zone = "${var.region}b"

  tags = {
    Name = "${var.project}-subnet-private2-${var.region}b"
    "kubernetes.io/role/internal-elb" = "1"
  }

  depends_on = [aws_vpc.vpc]

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_subnet" "database_subnet1" {
  count = length(var.subnet_cidrs.database) > 0 ? 1 : 0

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "${var.subnet_cidrs.database[0]}"
  availability_zone = "${var.region}a"

  tags = {
    Name = "${var.project}-subnet-database1-${var.region}b"
    "kubernetes.io/role/internal-elb" = "1"
  }

  depends_on = [aws_vpc.vpc]

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_subnet" "database_subnet2" {
  count = length(var.subnet_cidrs.database) > 0 ? 1 : 0

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "${var.subnet_cidrs.database[1]}"
  availability_zone = "${var.region}b"

  tags = {
    Name = "${var.project}-subnet-database2-${var.region}b"
    "kubernetes.io/role/internal-elb" = "1"
  }

  depends_on = [aws_vpc.vpc]

  lifecycle {
    ignore_changes = [tags]
  }
}