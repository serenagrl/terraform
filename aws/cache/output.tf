output "cache_password" {
  sensitive   = true
  value       = try(coalesce(var.password, random_password.cache_password.result), "null")
  description = "The initial password/token for cache when it was created."
}