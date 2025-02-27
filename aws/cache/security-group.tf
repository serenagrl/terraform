resource "aws_security_group" "cache_security_group" {
  name        = "${var.engine}-security-group"
  description = "Security group for ${var.engine}"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.engine}-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "vpn_cache_ingress_rule" {
  count = var.create_vpn_rule ? 1 : 0

  from_port         = 6379
  to_port           = 6379
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpn_local_ipv4_cidr
  security_group_id = aws_security_group.cache_security_group.id
}

resource "aws_vpc_security_group_ingress_rule" "eks_cache_ingress_rule" {
  count = var.create_eks_rule ? 1 : 0

  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.cache_security_group.id
  referenced_security_group_id = var.eks_security_group_id
}

resource "aws_vpc_security_group_egress_rule" "cache_egress_rule" {
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  security_group_id = aws_security_group.cache_security_group.id
}