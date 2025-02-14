resource "aws_db_subnet_group" "postgres_subnet_group" {
  count = local.demo.enabled ? 1 : 0

  name       = "postgres-subnet-group"
  subnet_ids = local.demo.postgres.subnets
  description =  "Subnet group for RDS PostgreSQL"

  tags = {
      Name = "postgres-subnet-group"
  }
}

resource "aws_security_group" "postgres_security_group" {
  count = local.demo.enabled ? 1 : 0

  name        = "postgres-security-group"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "postgres-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "vpn_postgres_ingress_rule" {
  count = local.demo.enabled ? 1 : 0

  security_group_id = aws_security_group.postgres_security_group[0].id

  from_port   = 5432
  to_port     = 5432
  ip_protocol = "tcp"
  cidr_ipv4   = "${local.vpn.local_ipv4_cidr}"
}

resource "aws_vpc_security_group_ingress_rule" "eks_postgres_ingress_rule" {
  count = local.demo.enabled ? 1 : 0

  security_group_id = aws_security_group.postgres_security_group[0].id

  from_port   = 5432
  to_port     = 5432
  ip_protocol = "tcp"
  referenced_security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

resource "aws_vpc_security_group_egress_rule" "postgres_egress_rule" {
  count = local.demo.enabled ? 1 : 0

  security_group_id = aws_security_group.postgres_security_group[0].id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "random_password" "postgres_password" {
  length  = 16
  special = false
}

resource "aws_db_instance" "rds_postgres" {
  count = local.demo.enabled ? 1 : 0

  identifier              = local.demo.postgres.initial_db
  engine                  = "postgres"
  engine_version          = local.demo.postgres.version
  instance_class          = local.demo.postgres.instance_type
  allocated_storage       = 20
  skip_final_snapshot     = true

  db_subnet_group_name    = aws_db_subnet_group.postgres_subnet_group[0].name
  vpc_security_group_ids  = [aws_security_group.postgres_security_group[0].id]
  publicly_accessible     = false
  multi_az                = local.demo.postgres.multi_az

  db_name                 = local.demo.postgres.initial_db
  username                = local.demo.postgres.username
  password                = coalesce(local.demo.postgres.password, random_password.postgres_password.result)

  tags = {
    Name = local.demo.postgres.initial_db
  }

  depends_on = [
    aws_security_group.postgres_security_group,
    aws_subnet.database_subnet1,
    aws_subnet.database_subnet2
  ]
}

output "postgres_password" {
  sensitive = true
  value = aws_db_instance.rds_postgres[0].password
  description = "The initial password for postgres when it was created."
}