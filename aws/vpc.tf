resource "aws_vpc" "vpc" {
  cidr_block = "${local.vpc_cidr}"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${local.project}-vpc"
  }
}