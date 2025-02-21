resource "aws_security_group" "cache_security_group" {
  count = local.cache.enabled ? 1 : 0

  name        = "${local.cache.engine}-security-group"
  description = "Security group for ${local.cache.engine}"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${local.cache.engine}-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "eks_cache_ingress_rule" {
  count = local.cache.enabled ? 1 : 0

  from_port                    = 6379
  to_port                      = 6379
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.cache_security_group[0].id
  referenced_security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

resource "aws_vpc_security_group_ingress_rule" "vpn_cache_ingress_rule" {
  count = local.cache.enabled && local.vpn.enabled ? 1 : 0

  from_port         = 6379
  to_port           = 6379
  ip_protocol       = "tcp"
  cidr_ipv4         = local.vpn.local_ipv4_cidr
  security_group_id = aws_security_group.cache_security_group[0].id
}

resource "aws_vpc_security_group_egress_rule" "cache_egress_rule" {
  count = local.cache.enabled ? 1 : 0

  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  security_group_id = aws_security_group.cache_security_group[0].id
}

resource "aws_elasticache_subnet_group" "cache_subnet_group" {
  count = local.cache.enabled ? 1 : 0

  name        = "${local.cache.engine}-subnet-group"
  subnet_ids  = local.cache.subnets
  description =  "Subnet group for ${local.cache.engine}"

  tags = {
      Name = "${local.cache.engine}-subnet-group"
  }
}

resource "random_password" "cache_password" {
  count = local.cache.enabled ? 1 : 0

  length  = 16
  special = false
}

resource "aws_elasticache_user" "cache_admin_user" {
  count = (local.cache.enabled && upper(local.cache.auth_type) == "USER") ? 1 : 0

  user_id       = local.cache.engine
  user_name     = "default" # Cannot change 1st default username
  access_string = "on ~* +@all"
  engine        = local.cache.engine

  authentication_mode {
    type      = "password"
    passwords = [coalesce(local.cache.password, random_password.cache_password[0].result)]
  }
}

resource "aws_elasticache_user_group" "cache_user_group" {
  count = (local.cache.enabled && upper(local.cache.auth_type) == "USER") ? 1 : 0

  engine        = local.cache.engine
  user_group_id = "${local.project}-${local.cache.engine}-users"
  user_ids      = [aws_elasticache_user.cache_admin_user[0].user_id]
}

resource "aws_cloudwatch_log_group" "cache_logs" {
  count = local.cache.enabled ? 1 : 0

  name              = "${local.cache.cluster_name}-logs"
  retention_in_days = 7
}

resource "aws_elasticache_replication_group" "cache" {
  count = local.cache.enabled ? 1 : 0

  replication_group_id       = local.cache.cluster_name
  description                = "Cache Cluster (${local.cache.engine})"
  engine                     = local.cache.engine
  node_type                  = local.cache.instance_type
  port                       = 6379
  cluster_mode               = local.cache.cluster_enabled ? "enabled" : "disabled"
  automatic_failover_enabled = local.cache.nodes_and_replicas == [1,0] ? false : true
  subnet_group_name          = aws_elasticache_subnet_group.cache_subnet_group[0].name
  security_group_ids         = [aws_security_group.cache_security_group[0].id]
  multi_az_enabled           = local.cache.multi_az
  num_node_groups            = local.cache.nodes_and_replicas[0]
  replicas_per_node_group    = local.cache.nodes_and_replicas[1]

  transit_encryption_enabled = true
  auth_token                 = upper(local.cache.auth_type) == "TOKEN" ? coalesce(local.cache.password, random_password.cache_password[0].result) : null

  user_group_ids             = upper(local.cache.auth_type) == "USER" ? [aws_elasticache_user_group.cache_user_group[0].user_group_id] : null

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.cache_logs[0].name
    destination_type = "cloudwatch-logs"
    log_format       = "text"
    log_type         = "slow-log"
  }

  depends_on = [
    aws_security_group.cache_security_group[0],
    aws_subnet.private_subnet1,
    aws_subnet.private_subnet2
  ]
}

output "cache_password" {
  sensitive   = true
  value       = try(coalesce(local.cache.password, random_password.cache_password[0].result), "null")
  description = "The initial password/token for cache when it was created."
}