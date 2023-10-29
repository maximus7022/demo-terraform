# ===============DB_HOSTNAME==================

resource "aws_ssm_parameter" "host_secret" {
  name        = var.host_secret_name
  description = "RDS hostname"
  type        = "String"
  value       = aws_db_instance.rds.address

  tags = { Name = var.host_secret_name }
}


# ===============DB_DATABASE==================

resource "aws_ssm_parameter" "database_secret" {
  name        = var.database_secret_name
  description = "RDS database"
  type        = "String"
  value       = var.db_name

  tags = { Name = var.database_secret_name }
}

# ===============DB_USERNAME==================

resource "aws_ssm_parameter" "username_secret" {
  name        = var.username_secret_name
  description = "RDS username"
  type        = "String"
  value       = var.username

  tags = { Name = var.username_secret_name }
}

# ===============DB_PASSWORD==================

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_!%^"
}

resource "aws_ssm_parameter" "password_secret" {
  name        = var.password_secret_name
  description = "RDS password"
  type        = "SecureString"
  value       = random_password.password.result

  tags = { Name = var.password_secret_name }
}
