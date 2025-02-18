resource "aws_db_subnet_group" "postgres_subnet_group" {
  count = local.postgres.enabled ? 1 : 0

  name        = "postgres-subnet-group"
  subnet_ids  = local.postgres.subnets
  description =  "Subnet group for RDS PostgreSQL"

  tags = {
      Name = "postgres-subnet-group"
  }
}

resource "aws_security_group" "postgres_security_group" {
  count = local.postgres.enabled ? 1 : 0

  name        = "postgres-security-group"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "postgres-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "vpn_postgres_ingress_rule" {
  count = local.postgres.enabled && local.vpn.enabled ? 1 : 0

  from_port         = 5432
  to_port           = 5432
  ip_protocol       = "tcp"
  cidr_ipv4         = local.vpn.local_ipv4_cidr
  security_group_id = aws_security_group.postgres_security_group[0].id
}

resource "aws_vpc_security_group_ingress_rule" "eks_postgres_ingress_rule" {
  count = local.postgres.enabled ? 1 : 0

  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.postgres_security_group[0].id
  referenced_security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

resource "aws_vpc_security_group_egress_rule" "postgres_egress_rule" {
  count = local.postgres.enabled ? 1 : 0

  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  security_group_id = aws_security_group.postgres_security_group[0].id
}

resource "random_password" "postgres_password" {
  length  = 16
  special = false
}

resource "aws_db_instance" "rds_postgres" {
  count = local.postgres.enabled ? 1 : 0

  identifier              = local.postgres.initial_db
  engine                  = "postgres"
  engine_version          = local.postgres.version
  instance_class          = local.postgres.instance_type
  allocated_storage       = 20
  skip_final_snapshot     = true

  db_subnet_group_name    = aws_db_subnet_group.postgres_subnet_group[0].name
  vpc_security_group_ids  = [aws_security_group.postgres_security_group[0].id]
  publicly_accessible     = false
  multi_az                = local.postgres.multi_az

  db_name                 = local.postgres.initial_db
  username                = local.postgres.username
  password                = coalesce(local.postgres.password, random_password.postgres_password.result)

  tags = {
    Name = local.postgres.initial_db
  }

  depends_on = [
    aws_security_group.postgres_security_group,
    aws_subnet.database_subnet1,
    aws_subnet.database_subnet2
  ]
}

output "postgres_password" {
  sensitive = true
  value = try(aws_db_instance.rds_postgres[0].password, "null")
  description = "The initial password for postgres when it was created."
}