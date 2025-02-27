resource "aws_db_subnet_group" "postgres_subnet_group" {
  name        = "postgres-subnet-group"
  subnet_ids  = var.subnet_ids
  description = "Subnet group for RDS PostgreSQL"

  tags = {
      Name = "postgres-subnet-group"
  }
}

resource "random_password" "postgres_password" {
  length  = 16
  special = false
}

resource "aws_db_instance" "rds_postgres" {
  identifier              = var.initial_db
  engine                  = "postgres"
  engine_version          = var.postgres_version
  instance_class          = var.instance_type
  allocated_storage       = 20
  skip_final_snapshot     = true

  db_subnet_group_name    = aws_db_subnet_group.postgres_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.postgres_security_group.id]
  publicly_accessible     = false
  multi_az                = var.multi_az

  db_name                 = var.initial_db
  username                = var.username
  password                = coalesce(var.password, random_password.postgres_password.result)

  tags = {
    Name = var.initial_db
  }

  depends_on = [
    aws_security_group.postgres_security_group,
  ]
}
