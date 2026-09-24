output "instance_id" {
  description = "RDS instance identifier."
  value       = aws_db_instance.this.identifier
}

output "address" {
  description = "RDS endpoint hostname."
  value       = aws_db_instance.this.address
}

output "security_group_id" {
  description = "Security group of the instance."
  value       = aws_security_group.this.id
}

output "secret_arn" {
  description = "Secret with connection details and DATABASE_URL."
  value       = aws_secretsmanager_secret.this.arn
}
