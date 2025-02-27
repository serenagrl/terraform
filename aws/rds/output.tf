output "postgres_password" {
  sensitive = true
  value = try(aws_db_instance.rds_postgres.password, "null")
  description = "The initial password for postgres when it was created."
}