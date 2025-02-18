resource "aws_security_group" "rabbitmq_security_group" {
  count = local.rabbitmq.enabled ? 1 : 0

  name        = "rabbitmq-security-group"
  description = "Security group for Amazon MQ RabbitMQ broker"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "rabbitmq-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "vpn_rabbitmq_ingress_rule" {
  count = local.rabbitmq.enabled && local.vpn.enabled ? 1 : 0

  from_port         = 5671
  to_port           = 5671
  ip_protocol       = "tcp"
  cidr_ipv4         = local.vpn.local_ipv4_cidr
  security_group_id = aws_security_group.rabbitmq_security_group[0].id
}

resource "aws_vpc_security_group_ingress_rule" "eks_rabbitmq_ingress_rule" {
  count = local.rabbitmq.enabled ? 1 : 0

  from_port                    = 5671
  to_port                      = 5671
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.rabbitmq_security_group[0].id
  referenced_security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

resource "aws_vpc_security_group_ingress_rule" "vpn_rabbitmq_portal_ingress_rule" {
  count = local.rabbitmq.enabled && local.vpn.enabled ? 1 : 0

  from_port         = 15671
  to_port           = 15671
  ip_protocol       = "tcp"
  cidr_ipv4         = local.vpn.local_ipv4_cidr
  security_group_id = aws_security_group.rabbitmq_security_group[0].id
}

resource "aws_vpc_security_group_ingress_rule" "eks_rabbitmq_portal_ingress_rule" {
  count = local.rabbitmq.enabled ? 1 : 0

  from_port                    = 15671
  to_port                      = 15671
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.rabbitmq_security_group[0].id
  referenced_security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

resource "aws_vpc_security_group_egress_rule" "rabbitmq_egress_rule" {
  count = local.rabbitmq.enabled ? 1 : 0

  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  security_group_id = aws_security_group.rabbitmq_security_group[0].id
}

resource "random_password" "rabbitmq_password" {
  length  = 16
  special = false
}

resource "aws_mq_broker" "rabbitmq" {
  count = local.rabbitmq.enabled ? 1 : 0

  broker_name                = local.rabbitmq.broker_name
  engine_type                = "RabbitMQ"
  engine_version             = local.rabbitmq.version
  auto_minor_version_upgrade = true
  host_instance_type         = local.rabbitmq.instance_type
  deployment_mode            = local.rabbitmq.mode
  publicly_accessible        = false
  subnet_ids                 = local.rabbitmq.subnets
  security_groups            = [aws_security_group.rabbitmq_security_group[0].id]

  user {
    username = local.rabbitmq.admin_username
    password = coalesce(local.rabbitmq.admin_password, random_password.rabbitmq_password.result)
  }

  depends_on = [
    aws_security_group.rabbitmq_security_group[0],
    aws_subnet.private_subnet1,
    aws_subnet.private_subnet2
  ]

}

output "rabbitmq_password" {
  sensitive   = true
  value       = try(aws_mq_broker.rabbitmq[0].user.*.password[0], "null")
  # value = coalesce(local.rabbitmq.admin_password, random_password.rabbitmq_password.result)
  description = "The initial password for rabbitmq when it was created."
}