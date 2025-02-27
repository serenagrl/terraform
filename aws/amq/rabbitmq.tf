
resource "random_password" "rabbitmq_password" {
  length  = 16
  special = false
}

resource "aws_mq_broker" "rabbitmq" {
  broker_name                = var.broker_name
  engine_type                = "RabbitMQ"
  engine_version             = var.rabbitmq_version
  auto_minor_version_upgrade = true
  host_instance_type         = var.instance_type
  deployment_mode            = var.mode
  publicly_accessible        = false
  security_groups            = [aws_security_group.rabbitmq_security_group.id]

  # Single instance only supports 1 subnet
  subnet_ids                 = upper(var.mode) == "SINGLE_INSTANCE" ? [var.subnet_ids[0]] : var.subnet_ids

  user {
    username = var.username
    password = coalesce(var.password, random_password.rabbitmq_password.result)
  }

  depends_on = [
    aws_security_group.rabbitmq_security_group,
  ]

}