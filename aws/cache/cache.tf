resource "aws_elasticache_subnet_group" "cache_subnet_group" {
  name        = "${var.engine}-subnet-group"
  subnet_ids  = var.subnet_ids
  description =  "Subnet group for ${var.engine}"

  tags = {
      Name = "${var.engine}-subnet-group"
  }
}

resource "aws_cloudwatch_log_group" "cache_logs" {
  name              = "${var.cluster_name}-logs"
  retention_in_days = 7
}

resource "aws_elasticache_replication_group" "cache" {
  replication_group_id       = var.cluster_name
  description                = "Cache Cluster (${var.engine})"
  engine                     = var.engine
  node_type                  = var.instance_type
  port                       = 6379
  cluster_mode               = var.cluster_enabled ? "enabled" : "disabled"
  automatic_failover_enabled = var.nodes_and_replicas == [1,0] ? false : true
  subnet_group_name          = aws_elasticache_subnet_group.cache_subnet_group.name
  security_group_ids         = [aws_security_group.cache_security_group.id]
  multi_az_enabled           = var.multi_az
  num_node_groups            = var.nodes_and_replicas[0]
  replicas_per_node_group    = var.nodes_and_replicas[1]

  transit_encryption_enabled = true
  auth_token                 = upper(var.auth_type) == "TOKEN" ? coalesce(var.password, random_password.cache_password.result) : null

  user_group_ids             = upper(var.auth_type) == "USER" ? [aws_elasticache_user_group.cache_user_group[0].user_group_id] : null

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.cache_logs.name
    destination_type = "cloudwatch-logs"
    log_format       = "text"
    log_type         = "slow-log"
  }

  depends_on = [
    aws_security_group.cache_security_group,
  ]
}