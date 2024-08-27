output "database_host" {
  value = aws_db_instance.db.address
}

output "database_user" {
  value = aws_db_instance.db.username
}

output "database_name" {
  value = aws_db_instance.db.db_name
}

output "database_port" {
  value = aws_db_instance.db.port
}

output "database_password" {
  value     = random_password.db_password.result
  sensitive = true
}
