resource "aws_security_group" "redis_security_group" {
  count = local.redis.enabled ? 1 : 0

  name        = "redis-security-group"
  description = "Security group for Redis"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "redis-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "eks_redis_ingress_rule" {
  count = local.redis.enabled ? 1 : 0

  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.redis_security_group[0].id
  referenced_security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

resource "aws_vpc_security_group_ingress_rule" "vpn_redis_ingress_rule" {
  count = local.redis.enabled && local.vpn.enabled ? 1 : 0

  from_port         = 6379
  to_port           = 6379
  ip_protocol       = "tcp"
  cidr_ipv4         = local.vpn.local_ipv4_cidr
  security_group_id = aws_security_group.redis_security_group[0].id
}

resource "aws_vpc_security_group_egress_rule" "redis_egress_rule" {
  count = local.redis.enabled ? 1 : 0

  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  security_group_id = aws_security_group.redis_security_group[0].id
}

resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  count = local.redis.enabled ? 1 : 0

  name        = "redis-subnet-group"
  subnet_ids  = local.redis.subnets
  description =  "Subnet group for Redis"

  tags = {
      Name = "redis-subnet-group"
  }
}

resource "random_password" "redis_password" {
  count = local.redis.enabled && local.redis.cluster.enabled ? 1 : 0

  length  = 16
  special = false
}

resource "aws_elasticache_user" "redis_admin_user" {
  count = (local.redis.enabled && local.redis.cluster.enabled &&
           upper(local.redis.cluster.auth_type) == "USER") ? 1 : 0

  user_id       = "redis"
  user_name     = "default" # Cannot change 1st default username
  access_string = "on ~* +@all"
  engine        = "redis"

  authentication_mode {
    type      = "password"
    passwords = [coalesce(local.redis.cluster.password, random_password.redis_password[0].result)]
  }
}

resource "aws_elasticache_user_group" "redis_user_group" {
  count = (local.redis.enabled && local.redis.cluster.enabled &&
           upper(local.redis.cluster.auth_type) == "USER") ? 1 : 0

  engine        = "redis"
  user_group_id = "${local.project}-redis-users"
  user_ids      = [aws_elasticache_user.redis_admin_user[0].user_id]
}

resource "aws_cloudwatch_log_group" "redis_logs" {
  count = local.redis.enabled ? 1 : 0

  name              = "${local.redis.cluster_name}-logs"
  retention_in_days = 7
}

resource "aws_elasticache_cluster" "redis" {
  count = local.redis.enabled && !local.redis.cluster.enabled ? 1 : 0

  cluster_id           = local.redis.cluster_name
  engine               = "redis"
  node_type            = local.redis.instance_type
  parameter_group_name = "default.redis7"
  engine_version       = local.redis.version
  port                 = 6379
  num_cache_nodes      = 1 # Must be one for Redis
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet_group[0].name
  security_group_ids   = [aws_security_group.redis_security_group[0].id]

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis_logs[0].name
    destination_type = "cloudwatch-logs"
    log_format       = "text"
    log_type         = "slow-log"
  }

  depends_on = [
    aws_security_group.redis_security_group[0],
    aws_subnet.private_subnet1,
    aws_subnet.private_subnet2
  ]
}

resource "aws_elasticache_replication_group" "redis" {
  count = local.redis.enabled && local.redis.cluster.enabled ? 1 : 0

  replication_group_id        = local.redis.cluster_name
  description                 = "Redis Cluster"
  engine                      = "redis"
  node_type                   = local.redis.instance_type
  port                        = 6379
  parameter_group_name        = "default.redis7.cluster.on"
  automatic_failover_enabled  = true
  subnet_group_name           = aws_elasticache_subnet_group.redis_subnet_group[0].name
  security_group_ids          = [aws_security_group.redis_security_group[0].id]
  multi_az_enabled            = local.redis.cluster.multi_az
  num_node_groups             = local.redis.cluster.node_groups
  replicas_per_node_group     = local.redis.cluster.replicas_per_node_group

  transit_encryption_enabled  = true
  auth_token                  = upper(local.redis.cluster.auth_type) == "TOKEN" ? coalesce(local.redis.cluster.password, random_password.redis_password[0].result) : null

  user_group_ids              = upper(local.redis.cluster.auth_type) == "USER" ? [aws_elasticache_user_group.redis_user_group[0].user_group_id] : null
  
  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis_logs[0].name
    destination_type = "cloudwatch-logs"
    log_format       = "text"
    log_type         = "slow-log"
  }

  depends_on = [
    aws_security_group.redis_security_group[0],
    aws_subnet.private_subnet1,
    aws_subnet.private_subnet2
  ]
}

output "redis_password" {
  sensitive   = true
  value       = try(random_password.redis_password[0].result, "null")
  description = "The initial password/token for redis when it was created."
}