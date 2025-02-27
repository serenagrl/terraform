output "rabbitmq_password" {
  sensitive   = true
  value       = try(aws_mq_broker.rabbitmq.user.*.password[0], "null")
  description = "The initial password for rabbitmq when it was created."
}