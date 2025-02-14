resource "aws_security_group" "rabbitmq_security_group" {
  count = local.demo.enabled ? 1 : 0

  name        = "rabbitmq-security-group"
  description = "Security group for Amazon MQ RabbitMQ broker"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "rabbitmq-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "vpn_rabbitmq_ingress_rule" {
  count = local.demo.enabled ? 1 : 0

  security_group_id = aws_security_group.rabbitmq_security_group[0].id

  from_port   = 5671
  to_port     = 5671
  ip_protocol = "tcp"
  cidr_ipv4   = "${local.vpn.local_ipv4_cidr}"
}

resource "aws_vpc_security_group_ingress_rule" "eks_rabbitmq_ingress_rule" {
  count = local.demo.enabled ? 1 : 0

  security_group_id = aws_security_group.rabbitmq_security_group[0].id

  from_port   = 5671
  to_port     = 5671
  ip_protocol = "tcp"
  referenced_security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

resource "aws_vpc_security_group_ingress_rule" "vpn_rabbitmq_portal_ingress_rule" {
  count = local.demo.enabled ? 1 : 0

  security_group_id = aws_security_group.rabbitmq_security_group[0].id

  from_port   = 15671
  to_port     = 15671
  ip_protocol = "tcp"
  cidr_ipv4   = "${local.vpn.local_ipv4_cidr}"
}

resource "aws_vpc_security_group_ingress_rule" "eks_rabbitmq_portal_ingress_rule" {
  count = local.demo.enabled ? 1 : 0

  security_group_id = aws_security_group.rabbitmq_security_group[0].id

  from_port   = 15671
  to_port     = 15671
  ip_protocol = "tcp"
  referenced_security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

resource "aws_vpc_security_group_egress_rule" "rabbitmq_egress_rule" {
  count = local.demo.enabled ? 1 : 0

  security_group_id = aws_security_group.rabbitmq_security_group[0].id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "random_password" "rabbitmq_password" {
  length  = 16
  special = false
}

resource "aws_mq_broker" "rabbitmq" {
  count = local.demo.enabled ? 1 : 0

  broker_name                = "rabbitmq"
  engine_type                = "RabbitMQ"
  engine_version             = local.demo.rabbitmq.version
  auto_minor_version_upgrade = true
  host_instance_type         = local.demo.rabbitmq.instance_type
  deployment_mode            = local.demo.rabbitmq.mode
  publicly_accessible        = false

  subnet_ids      = local.demo.rabbitmq.subnets
  security_groups = [aws_security_group.rabbitmq_security_group[0].id]

  user {
    username = local.demo.rabbitmq.admin_username
    password = coalesce(local.demo.rabbitmq.admin_password, random_password.rabbitmq_password.result)
  }

  depends_on = [
    aws_security_group.rabbitmq_security_group[0],
    aws_subnet.private_subnet1,
    aws_subnet.private_subnet2
  ]

}

output "rabbitmq_password" {
  sensitive = true
  value = coalesce(local.demo.rabbitmq.admin_password, random_password.rabbitmq_password.result)
  description = "The initial password for rabbitmq when it was created."
}