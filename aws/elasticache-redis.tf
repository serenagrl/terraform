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
  replicas_per_node_group     = local.redis.cluster.replicas

  depends_on = [
    aws_security_group.redis_security_group[0],
    aws_subnet.private_subnet1,
    aws_subnet.private_subnet2
  ]
}