output "postgres_password" {
  sensitive = true
  value = try(aws_db_instance.rds_postgres[0].password, "null")
  description = "The initial password for postgres when it was created."

  depends_on = [ aws_db_instance.rds_postgres ]
}

output "sqlserver_password" {
  sensitive = true
  value = try(aws_db_instance.rds_sqlserver[0].password, "null")
  description = "The initial password for sqlserver when it was created."

  depends_on = [ aws_db_instance.rds_sqlserver ]
}