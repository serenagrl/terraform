resource "aws_security_group" "rabbitmq_security_group" {
  name        = "rabbitmq-security-group"
  description = "Security group for Amazon MQ RabbitMQ broker"
  vpc_id      = var.vpc_id

  tags = {
    Name = "rabbitmq-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "vpn_rabbitmq_ingress_rule" {
  count = var.create_vpn_rule  ? 1 : 0

  from_port         = 5671
  to_port           = 5671
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpn_local_ipv4_cidr
  security_group_id = aws_security_group.rabbitmq_security_group.id
}

resource "aws_vpc_security_group_ingress_rule" "eks_rabbitmq_ingress_rule" {
  count = var.create_eks_rule ? 1 : 0

  from_port                    = 5671
  to_port                      = 5671
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.rabbitmq_security_group.id
  referenced_security_group_id = var.eks_security_group_id
}

resource "aws_vpc_security_group_ingress_rule" "vpn_rabbitmq_portal_ingress_rule" {
  count = var.create_vpn_rule  ? 1 : 0

  from_port         = 15671
  to_port           = 15671
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpn_local_ipv4_cidr
  security_group_id = aws_security_group.rabbitmq_security_group.id
}

resource "aws_vpc_security_group_ingress_rule" "eks_rabbitmq_portal_ingress_rule" {
  count = var.create_eks_rule  ? 1 : 0

  from_port                    = 15671
  to_port                      = 15671
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.rabbitmq_security_group.id
  referenced_security_group_id = var.eks_security_group_id
}

resource "aws_vpc_security_group_egress_rule" "rabbitmq_egress_rule" {
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  security_group_id = aws_security_group.rabbitmq_security_group.id
}
