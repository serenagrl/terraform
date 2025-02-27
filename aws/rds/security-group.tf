resource "aws_security_group" "postgres_security_group" {
  name        = "postgres-security-group"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = var.vpc_id

  tags = {
    Name = "postgres-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "vpn_postgres_ingress_rule" {
  count = var.create_vpn_rule ? 1 : 0

  from_port         = 5432
  to_port           = 5432
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpn_local_ipv4_cidr
  security_group_id = aws_security_group.postgres_security_group.id
}

resource "aws_vpc_security_group_ingress_rule" "eks_postgres_ingress_rule" {
  count = var.create_eks_rule ? 1 : 0

  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.postgres_security_group.id
  referenced_security_group_id = var.eks_security_group_id
}

resource "aws_vpc_security_group_egress_rule" "postgres_egress_rule" {
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  security_group_id = aws_security_group.postgres_security_group.id
}