# One RDS PostgreSQL instance plus a Secrets Manager secret the app consumes.
#
# The master password is generated as an ephemeral value and passed through
# write-only arguments, so it never lands in Terraform state or plan output.
# The secret holds JSON: username, password, host, port, dbname and `url`
# (a ready-to-use DATABASE_URL with sslmode=require). To rotate, bump
# `password_version` and apply, then restart the ECS services.

resource "aws_db_subnet_group" "this" {
  name       = var.name
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "this" {
  name_prefix = "${var.name}-db-"
  description = "PostgreSQL access for ${var.name}"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "postgres" {
  for_each = var.allowed_security_group_ids

  security_group_id            = aws_security_group.this.id
  referenced_security_group_id = each.value
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  description                  = "PostgreSQL from ${each.key}"
}

ephemeral "random_password" "master" {
  length  = 40
  special = false
}

# Own parameter group so settings can change later without swapping groups
# on a live instance (the default group is read-only).
resource "aws_db_parameter_group" "this" {
  name_prefix = "${var.name}-"
  family      = "postgres${split(".", var.engine_version)[0]}"
  description = "Parameters for ${var.name}"

  # Static parameter: AWS records it as pending-reboot; matching that avoids a
  # perpetual diff.
  parameter {
    name         = "rds.force_ssl"
    value        = "1"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = tostring(var.log_min_duration_ms)
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Created up front so exports get a retention period and our KMS key.
resource "aws_cloudwatch_log_group" "this" {
  for_each = toset(["postgresql", "upgrade"])

  name              = "/aws/rds/instance/${var.name}/${each.key}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn
}

resource "aws_db_instance" "this" {
  identifier     = var.name
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  db_name             = var.db_name
  username            = var.username
  password_wo         = ephemeral.random_password.master.result
  password_wo_version = var.password_version

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = var.kms_key_arn

  db_subnet_group_name                = aws_db_subnet_group.this.name
  vpc_security_group_ids              = [aws_security_group.this.id]
  parameter_group_name                = aws_db_parameter_group.this.name
  publicly_accessible                 = false
  multi_az                            = var.multi_az
  iam_database_authentication_enabled = true
  enabled_cloudwatch_logs_exports     = keys(aws_cloudwatch_log_group.this)

  backup_retention_period   = var.backup_retention_days
  backup_window             = "20:00-21:00" # 01:30-02:30 IST
  maintenance_window        = "sun:21:30-sun:22:30"
  copy_tags_to_snapshot     = true
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.name}-final"

  auto_minor_version_upgrade            = true
  allow_major_version_upgrade           = false
  apply_immediately                     = var.apply_immediately
  performance_insights_enabled          = true
  performance_insights_kms_key_id       = var.kms_key_arn
  performance_insights_retention_period = 7
}

resource "aws_secretsmanager_secret" "this" {
  name                    = var.secret_name
  description             = "Connection details for ${var.name}"
  kms_key_id              = var.kms_key_arn
  recovery_window_in_days = var.secret_recovery_window_days
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.id
  secret_string_wo = jsonencode({
    engine   = "postgres"
    username = var.username
    password = ephemeral.random_password.master.result
    host     = aws_db_instance.this.address
    port     = aws_db_instance.this.port
    dbname   = var.db_name
    url      = "postgresql+asyncpg://${var.username}:${ephemeral.random_password.master.result}@${aws_db_instance.this.address}:${aws_db_instance.this.port}/${var.db_name}?sslmode=require"
  })
  secret_string_wo_version = var.password_version
}
