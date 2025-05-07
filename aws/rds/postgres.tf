resource "aws_db_subnet_group" "postgres_subnet_group" {
  count = upper(var.engine) == "POSTGRES" ? 1 : 0

  name        = "postgres-subnet-group"
  subnet_ids  = aws_subnet.database_subnets.*.id
  description = "Subnet group for RDS PostgreSQL"

  tags = {
      Name = "postgres-subnet-group"
  }
}

resource "aws_db_instance" "rds_postgres" {
  count = upper(var.engine) == "POSTGRES" ? 1 : 0

  identifier              = var.initial_db
  engine                  = "postgres"
  engine_version          = var.engine_version
  instance_class          = var.instance_type
  allocated_storage       = 20
  skip_final_snapshot     = true

  db_subnet_group_name    = aws_db_subnet_group.postgres_subnet_group[0].name
  vpc_security_group_ids  = [aws_security_group.postgres_security_group[0].id]
  publicly_accessible     = false
  multi_az                = var.multi_az

  db_name                 = var.initial_db
  username                = var.username
  password                = coalesce(var.password, random_password.password.result)

  tags = {
    Name = var.initial_db
  }

  depends_on = [
    aws_security_group.postgres_security_group,
  ]
}
