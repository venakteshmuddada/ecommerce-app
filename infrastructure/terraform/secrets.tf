resource "aws_secretsmanager_secret" "db_secret" {
  name        = "ecommerce-db-credentials"
  description = "Database credentials for ecommerce app"
}

resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}
