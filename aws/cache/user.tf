resource "random_password" "cache_password" {
  length  = 16
  special = false
}

resource "aws_elasticache_user" "cache_admin_user" {
  count = upper(var.auth_type) == "USER" ? 1 : 0

  user_id       = var.engine
  user_name     = "default" # Cannot change 1st default username
  access_string = "on ~* +@all"
  engine        = var.engine

  authentication_mode {
    type      = "password"
    passwords = [coalesce(var.password, random_password.cache_password.result)]
  }
}

resource "aws_elasticache_user_group" "cache_user_group" {
  count = upper(var.auth_type) == "USER" ? 1 : 0

  engine        = var.engine
  user_group_id = "${var.engine}-users"
  user_ids      = [aws_elasticache_user.cache_admin_user[0].user_id]
}